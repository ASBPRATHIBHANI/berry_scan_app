import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Amplify Imports
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import '../models/ScanHistory.dart';

// Services & Models
import '../services/ai_service.dart';
import '../services/language_service.dart';

class ResultScreen extends StatefulWidget {
  final File imageFile;
  final DiseaseDetection detection;
  final int? userId;

  const ResultScreen({
    super.key,
    required this.imageFile,
    required this.detection,
    this.userId,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _treatmentData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTreatmentAndSaveHistory();
  }

  // =========================================================
  // ☁️ DUAL DATA SYNC: AWS AMPLIFY & RDS (LAMBDA)
  // =========================================================
  Future<void> _fetchTreatmentAndSaveHistory() async {
    // 1. Guard: Ensure it's a valid strawberry leaf detection
    if (!widget.detection.isValidLeaf) {
      setState(() {
        _isLoading = false;
        _errorMessage = "No valid strawberry leaf detected for diagnosis.";
      });
      return;
    }

    // 2. Accuracy Guard
    if (widget.detection.confidence < 0.30) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            "The image quality was too low for a reliable diagnosis.";
      });
      return;
    }

    try {
      // Standardizing the key for Database (e.g., "Leaf Spot" -> "leaf_spot")
      final String diseaseKey = widget.detection.diseaseName
          .toLowerCase()
          .trim()
          .replaceAll(' ', '_');

      bool isHealthy = diseaseKey.contains("healthy");

      // 3. Parallel Cloud Tasks
      List<Future> cloudTasks = [];

      // Task A: Save to RDS via Lambda
      if (widget.userId != null && widget.userId != 0) {
        cloudTasks.add(_saveHistoryToRDS(diseaseKey));
      }

      // Task B: Save to Amplify (Local History)
      cloudTasks.add(_saveToAmplifyHistory(widget.detection.diseaseName));

      // Task C: Fetch Treatment
      if (!isHealthy) {
        cloudTasks.add(_fetchTreatmentData(diseaseKey));
      }

      await Future.wait(cloudTasks);
    } catch (e) {
      debugPrint("❌ Cloud sync error: $e");
      if (mounted) {
        setState(
          () => _errorMessage = "Connection error. Results may be incomplete.",
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- METHOD 1: SAVE TO AMPLIFY ---
  Future<void> _saveToAmplifyHistory(String diseaseName) async {
    try {
      final newEntry = ScanHistory(
        disease: diseaseName,
        confidence: widget.detection.confidence,
        timestamp: TemporalDateTime.now(),
      );

      final request = ModelMutations.create(newEntry);
      final response = await Amplify.API.mutate(request: request).response;

      if (response.hasErrors) {
        debugPrint("❌ Amplify Mutation Errors: ${response.errors}");
      } else {
        debugPrint("✅ Saved to Amplify History successfully");
      }
    } catch (e) {
      debugPrint("❌ Amplify Save Error: $e");
    }
  }

  // --- METHOD 2: SAVE TO RDS (Critical fix for DB Storage) ---
  Future<void> _saveHistoryToRDS(String diseaseKey) async {
    const String historySaveUrl =
        "https://qyv6alj7jytr62lmu5rj35mbru0lnrnn.lambda-url.us-east-1.on.aws/";

    try {
      // We use explicit string keys to ensure Lambda parses the JSON correctly
      final Map<String, dynamic> payload = {
        "action": "save",
        "user_id": widget.userId,
        "disease_name": diseaseKey,
        "confidence": widget.detection.confidence,
      };

      final response = await http
          .post(
            Uri.parse(historySaveUrl),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint("✅ RDS Save Success: ${response.body}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Diagnosis saved to your history"),
              backgroundColor: Color(0xFF3A6B4E),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        debugPrint(
          "❌ RDS Save Failed (${response.statusCode}): ${response.body}",
        );
      }
    } catch (e) {
      debugPrint("❌ RDS Save Error: $e");
    }
  }

  // --- METHOD 3: FETCH TREATMENT ---
  Future<void> _fetchTreatmentData(String diseaseKey) async {
    const String treatmentUrl =
        "https://x7vt2xpbx7lh2h4dn4e2bcymma0rkpsd.lambda-url.us-east-1.on.aws/";

    try {
      final response = await http
          .post(
            Uri.parse(treatmentUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"disease": diseaseKey}),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        setState(() {
          _treatmentData = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint("❌ Treatment Fetch Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageService>(context);

    double rawConf = widget.detection.confidence;
    double displayPercent = (rawConf > 1.0) ? rawConf / 100.0 : rawConf;
    displayPercent = displayPercent.clamp(0.0, 1.0);

    bool isHealthy = widget.detection.diseaseName.toLowerCase().contains(
      "healthy",
    );
    Color statusColor = isHealthy
        ? const Color(0xFF3A6B4E)
        : const Color(0xFFE57373);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          language.getText('result'),
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 280.h,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(widget.imageFile),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              transform: Matrix4.translationValues(0.0, -40.0, 0.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35.r),
                  topRight: Radius.circular(35.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 25.h),
              child: Column(
                children: [
                  _buildHeaderInfo(statusColor, isHealthy),
                  SizedBox(height: 30.h),
                  CircularPercentIndicator(
                    radius: 75.r,
                    lineWidth: 14.0,
                    animation: true,
                    percent: displayPercent,
                    center: _buildConfidenceText(displayPercent, language),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: statusColor,
                    backgroundColor: Colors.grey.shade100,
                  ),
                  SizedBox(height: 35.h),
                  const Divider(thickness: 1, color: Color(0xFFF1F1F1)),
                  SizedBox(height: 20.h),
                  _buildSectionTitle(language.getText('treatment_advice')),
                  SizedBox(height: 18.h),
                  _buildTreatmentContent(language, isHealthy),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(Color color, bool isHealthy) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isHealthy ? Icons.verified_user : Icons.warning_amber_rounded,
            color: color,
            size: 24.sp,
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.detection.diseaseName.replaceAll('_', ' ').toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              Text(
                DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceText(double percent, LanguageService lang) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${(percent * 100).toInt()}%",
          style: GoogleFonts.poppins(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          lang.getText('accuracy'),
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTreatmentContent(LanguageService lang, bool isHealthy) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF3A6B4E)),
      );
    }

    if (isHealthy) {
      return _buildTreatmentCard(
        "Maintenance Tips",
        "Your strawberry plant is in great health! Keep doing what you're doing. Ensure it gets 6-8 hours of sunlight and water the base, not the leaves.",
        const Color(0xFF3A6B4E),
        Icons.eco_outlined,
      );
    }

    if (_errorMessage != null && _treatmentData == null) {
      return Text(
        _errorMessage!,
        style: GoogleFonts.poppins(
          color: Colors.grey.shade600,
          fontSize: 13.sp,
        ),
      );
    }

    return Column(
      children: [
        _buildTreatmentCard(
          lang.getText('organic_cure'),
          _treatmentData?['Recommendation_text'] ??
              "No organic treatment found.",
          const Color(0xFF4CAF50),
          Icons.eco_outlined,
        ),
        SizedBox(height: 16.h),
        _buildTreatmentCard(
          lang.getText('chemical_cure'),
          _treatmentData?['Prevention_Tips'] ?? "No chemical data available.",
          const Color(0xFF2196F3),
          Icons.science_outlined,
        ),
      ],
    );
  }

  Widget _buildTreatmentCard(
    String title,
    String content,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22.sp),
              SizedBox(width: 10.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 13.5.sp,
              color: const Color(0xFF444444),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
