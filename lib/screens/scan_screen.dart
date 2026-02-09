import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Services
import '../services/ai_service.dart';
import '../services/language_service.dart';

// Screens
import 'result_screen.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  final int _selectedIndex = 1;

  // AI & Camera
  final AIService _aiService = AIService();
  CameraController? _controller;

  bool _isProcessing = false; // Controls the stream loop
  bool _isCapturing = false; // UI overlay during high-res capture
  bool _isWaitingForCloud = false; // Controls the loading spinner feedback

  // Detection Data
  DiseaseDetection? _currentDetection;
  Rect? _highlightRect;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.yuv420
            : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() {});
      _startImageStream();
    } catch (e) {
      debugPrint("Camera Initialization Error: $e");
    }
  }

  void _stopCamera() {
    if (_controller?.value.isStreamingImages ?? false) {
      _controller?.stopImageStream();
    }
    _controller?.dispose();
    _controller = null;
  }

  void _startImageStream() {
    _controller?.startImageStream((CameraImage image) async {
      if (_isProcessing || _isCapturing || !mounted) return;

      setState(() {
        _isProcessing = true;
        _isWaitingForCloud = true; // Show that we are talking to AWS
      });

      try {
        final result = await _aiService.classifyCameraImage(image);

        if (mounted) {
          setState(() {
            _isWaitingForCloud = false; // Request finished

            // Validate: Only show if it's a leaf and confidence is > 50%
            if (result.isValidLeaf && result.confidence > 0.50) {
              _currentDetection = result;

              if (result.bbox != null && result.bbox!.length == 4) {
                _highlightRect = _scaleRectToScreen(
                  result.bbox!,
                  Size(image.width.toDouble(), image.height.toDouble()),
                  MediaQuery.of(context).size,
                );
              }
            } else {
              // Hide data if it's the floor, a wall, or a low-confidence guess
              _currentDetection = null;
              _highlightRect = null;
            }
          });
        }
      } catch (e) {
        debugPrint("Stream error: $e");
        if (mounted) setState(() => _isWaitingForCloud = false);
      }

      // 1.2s delay provides a balance between real-time feel and battery/cost savings
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) _isProcessing = false;
    });
  }

  Rect _scaleRectToScreen(List<double> bbox, Size cameraSize, Size screenSize) {
    // Standard scaling for CameraPreview
    double scaleX = screenSize.width / cameraSize.height;
    double scaleY = screenSize.height / cameraSize.width;

    return Rect.fromLTWH(
      bbox[0] * scaleX,
      bbox[1] * scaleY,
      bbox[2] * scaleX,
      bbox[3] * scaleY,
    );
  }

  Future<void> _captureAndNavigate() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing)
      return;

    setState(() => _isCapturing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }

      final XFile file = await _controller!.takePicture();
      File imageFile = File(file.path);

      // Perform one high-res classification for the result screen
      final finalDetection = await _aiService.classifyImage(imageFile);

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              imageFile: imageFile,
              detection: finalDetection,
              userId: userId,
            ),
          ),
        );

        if (mounted) {
          setState(() {
            _isCapturing = false;
            _currentDetection = null;
            _highlightRect = null;
          });
          _initializeCamera();
        }
      }
    } catch (e) {
      debugPrint("Capture Error: $e");
      if (mounted) {
        setState(() => _isCapturing = false);
        _startImageStream();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageService>(context);
    final size = MediaQuery.of(context).size;

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF3A6B4E)),
        ),
      );
    }

    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 📷 Camera Preview
          Center(
            child: Transform.scale(
              scale: scale,
              child: CameraPreview(_controller!),
            ),
          ),

          // 🔳 Viewfinder Overlay
          Center(
            child: Container(
              width: 280.w,
              height: 280.w,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),

          // 🟥 DISEASE HIGHLIGHT BOX
          if (_highlightRect != null &&
              !_isCapturing &&
              (_currentDetection?.isValidLeaf ?? false))
            Positioned.fromRect(
              rect: _highlightRect!,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    color: Colors.redAccent,
                    child: Text(
                      "${_currentDetection?.diseaseName} ${((_currentDetection?.confidence ?? 0) * 100).toInt()}%",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 🏷️ Guidance Message
          Positioned(
            top: 120.h,
            left: 40.w,
            right: 40.w,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isWaitingForCloud)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  if (_isWaitingForCloud) SizedBox(width: 10.w),
                  Text(
                    _currentDetection != null
                        ? _currentDetection!.toString()
                        : "🔍 Aim at a Strawberry Leaf",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ☁️ Full Processing Overlay
          if (_isCapturing)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20.h),
                    Text(
                      "Analyzing Disease Area...",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 🧭 Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: 24.h, bottom: 10.h),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    language.getText('point_leaf'),
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Camera Button Stack with Animated Ring
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isWaitingForCloud)
                        SizedBox(
                          width: 82.w,
                          height: 82.w,
                          child: const CircularProgressIndicator(
                            color: Color(0xFF3A6B4E),
                            strokeWidth: 3,
                          ),
                        ),
                      GestureDetector(
                        onTap: _isCapturing ? null : _captureAndNavigate,
                        child: Container(
                          width: 72.w,
                          height: 72.w,
                          decoration: BoxDecoration(
                            color: _isCapturing
                                ? Colors.grey
                                : const Color(0xFF3A6B4E),
                            shape: BoxShape.circle,
                            boxShadow: [
                              if (!_isCapturing)
                                BoxShadow(
                                  color: const Color(
                                    0xFF3A6B4E,
                                  ).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 32.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),
                  _buildBottomNavBar(context, language),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, LanguageService language) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            Icons.home_outlined,
            language.getText('home'),
            0,
          ),
          _buildNavItem(
            context,
            Icons.document_scanner,
            language.getText('scan'),
            1,
          ),
          _buildNavItem(
            context,
            Icons.pie_chart_outline,
            language.getText('history'),
            2,
          ),
          _buildNavItem(
            context,
            Icons.settings_outlined,
            language.getText('settings'),
            3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == _selectedIndex || _isCapturing) return;
        Widget page;
        switch (index) {
          case 0:
            page = const HomeScreen();
            break;
          case 2:
            page = const HistoryScreen();
            break;
          case 3:
            page = const SettingsScreen();
            break;
          default:
            return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF3A6B4E) : Colors.grey,
            size: 24.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: isSelected ? const Color(0xFF3A6B4E) : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
