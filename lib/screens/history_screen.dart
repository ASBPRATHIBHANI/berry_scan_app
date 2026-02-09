import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:intl/intl.dart';

// Services
import '../services/language_service.dart';
import '../services/ai_service.dart';

// Models
import '../models/ScanHistory.dart';

// Screens
import 'home_screen.dart';
import 'scan_screen.dart';
import 'settings_screen.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final int _selectedIndex = 2;

  List<ScanHistory> _allHistory = [];
  List<ScanHistory> _filteredHistory = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  // 1. Fetch Data from AWS
  Future<void> _fetchHistory() async {
    try {
      final request = ModelQueries.list(ScanHistory.classType);
      final response = await Amplify.API.query(request: request).response;

      final data = response.data?.items;
      if (data != null) {
        final sortedList = data.whereType<ScanHistory>().toList();

        sortedList.sort((a, b) {
          if (a.timestamp == null || b.timestamp == null) return 0;
          return b.timestamp!.compareTo(a.timestamp!);
        });

        if (mounted) {
          setState(() {
            _allHistory = sortedList;
            _filteredHistory = sortedList;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. Delete Logic (AWS Amplify Mutation)
  Future<void> _deleteHistoryItem(ScanHistory item, int index) async {
    try {
      final request = ModelMutations.delete(item);
      final response = await Amplify.API.mutate(request: request).response;

      if (response.hasErrors) {
        debugPrint('Errors deleting item: ${response.errors}');
        _fetchHistory(); // Refresh to restore item if delete failed
      } else {
        debugPrint('Item deleted successfully');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${item.disease} record deleted"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error deleting history item: $e');
      _fetchHistory(); // Refresh to restore item if error occurred
    }
  }

  void _runFilter(String enteredKeyword) {
    List<ScanHistory> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allHistory;
    } else {
      results = _allHistory
          .where(
            (item) => item.disease.toLowerCase().contains(
              enteredKeyword.toLowerCase(),
            ),
          )
          .toList();
    }

    setState(() {
      _filteredHistory = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageService>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: const [
                    TextSpan(text: 'BerryScan'),
                    TextSpan(
                      text: '.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Center(
                child: Text(
                  language.getText('scan_history'),
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: _searchController,
                onChanged: (value) => _runFilter(value),
                decoration: InputDecoration(
                  labelText: 'Search History',
                  hintText: 'e.g. Anthracnose',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _runFilter('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14.h,
                    horizontal: 16.w,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredHistory.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoryList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(language),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 60.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            "No records found",
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.separated(
      itemCount: _filteredHistory.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = _filteredHistory[index];
        final isHealthy = item.disease.toLowerCase().contains("healthy");

        String formattedDate = "Unknown Date";
        if (item.timestamp != null) {
          try {
            DateTime dt = DateTime.parse(item.timestamp.toString()).toLocal();
            formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(dt);
          } catch (e) {
            formattedDate = "Invalid Date";
          }
        }

        // --- SWIPE TO DELETE WRAPPER ---
        return Dismissible(
          key: Key(item.id), // Ensure your model has a unique ID
          direction: DismissDirection.endToStart, // Swipe left to delete
          onDismissed: (direction) {
            // Remove from local lists immediately for smooth UI
            setState(() {
              _filteredHistory.removeAt(index);
              _allHistory.removeWhere((e) => e.id == item.id);
            });
            // Perform actual delete on cloud
            _deleteHistoryItem(item, index);
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.w),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            elevation: 2,
            margin: EdgeInsets.zero, // Card handles its own shape
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
              leading: CircleAvatar(
                backgroundColor: isHealthy
                    ? Colors.green[100]
                    : Colors.red[100],
                child: Icon(
                  isHealthy ? Icons.check : Icons.warning,
                  color: isHealthy ? Colors.green : Colors.red,
                ),
              ),
              title: Text(
                item.disease,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              subtitle: Text(
                formattedDate,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
              trailing: item.confidence != null
                  ? Text(
                      "${(item.confidence! * 100).toStringAsFixed(1)}%",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultScreen(
                      imageFile: File(''),
                      detection: DiseaseDetection(
                        diseaseName: item.disease,
                        confidence: item.confidence ?? 0.0,
                        isValidLeaf: true,
                        classIndex: 0,
                      ),
                      userId: 0,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav(LanguageService language) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, language.getText('home'), 0),
          _buildNavItem(
            Icons.document_scanner_outlined,
            language.getText('scan'),
            1,
          ),
          _buildNavItem(Icons.pie_chart, language.getText('history'), 2),
          _buildNavItem(
            Icons.settings_outlined,
            language.getText('settings'),
            3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == _selectedIndex) return;
        Widget screen;
        switch (index) {
          case 0:
            screen = const HomeScreen();
            break;
          case 1:
            screen = const ScanScreen();
            break;
          case 3:
            screen = const SettingsScreen();
            break;
          default:
            return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? const Color.fromARGB(255, 33, 150, 243)
                : Colors.grey,
            size: 24.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              color: isSelected
                  ? const Color.fromARGB(255, 33, 150, 243)
                  : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
