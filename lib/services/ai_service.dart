import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class DiseaseDetection {
  final String diseaseName;
  final double confidence;
  final int classIndex;
  final List<double>? bbox;
  final bool isValidLeaf; // ✅ NEW: To tell the UI if a leaf was actually found

  DiseaseDetection({
    required this.diseaseName,
    required this.confidence,
    required this.classIndex,
    this.bbox,
    this.isValidLeaf = true,
  });

  @override
  String toString() => isValidLeaf
      ? '$diseaseName (${(confidence * 100).toStringAsFixed(1)}%)'
      : diseaseName; // Returns "Searching..." or error messages
}

class AIService {
  // ✅ Your verified Lambda URL
  final String _cloudUrl =
      "https://qzsh253yhrcwkl3nrnvxueqvjq0qeekb.lambda-url.us-east-1.on.aws/";

  Future<void> loadModel() async {
    print("✅ AWS Cloud AI Service Ready");
  }

  // 📸 PHASE 1: Static Image Analysis
  Future<DiseaseDetection> classifyImage(File imageFile) async {
    try {
      final List<int> imageBytes = await imageFile.readAsBytes();

      img.Image? original = img.decodeImage(Uint8List.fromList(imageBytes));
      if (original == null) return _errorResult("Invalid Image");

      img.Image resized = img.copyResize(original, width: 640, height: 640);
      final List<int> jpegBytes = img.encodeJpg(resized, quality: 85);

      final String base64Image = base64Encode(jpegBytes);

      final response = await http.post(
        Uri.parse(_cloudUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"image": base64Image}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return _parseResponse(data);
      } else {
        return _errorResult("Server Error (${response.statusCode})");
      }
    } catch (e) {
      return _errorResult("Cloud Connection Failed");
    }
  }

  // 🎥 PHASE 2: Live Camera Stream Analysis
  Future<DiseaseDetection> classifyCameraImage(CameraImage cameraImage) async {
    try {
      img.Image? image = _convertYUV420ToImage(cameraImage);
      if (image == null) return _errorResult("Frame Error");

      // Resize for stream efficiency (match Lambda input)
      img.Image smallImage = img.copyResize(image, width: 480);
      final List<int> jpegBytes = img.encodeJpg(smallImage, quality: 45);

      final String base64Image = base64Encode(jpegBytes);

      final response = await http.post(
        Uri.parse(_cloudUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"image": base64Image}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return _parseResponse(data);
      }
      return _errorResult("Searching...", isLeaf: false);
    } catch (e) {
      return _errorResult("Network Busy", isLeaf: false);
    }
  }

  // ✅ Standardized parsing for both Static and Stream results
  DiseaseDetection _parseResponse(Map<String, dynamic> data) {
    // Check if Lambda flagged this as a successful leaf detection
    bool isLeafFound = data['status'] == "success";

    List<double>? parsedBbox;
    if (data['bbox'] != null && isLeafFound) {
      parsedBbox = List<double>.from(
        data['bbox'].map((item) => item.toDouble()),
      );
    }

    return DiseaseDetection(
      diseaseName: isLeafFound ? _formatLabel(data['disease']) : "Searching...",
      confidence: (data['confidence'] ?? 0.0).toDouble(),
      classIndex: data['index'] ?? -1,
      bbox: parsedBbox,
      isValidLeaf: isLeafFound,
    );
  }

  // 📷 YUV420 to RGB conversion
  img.Image? _convertYUV420ToImage(CameraImage cameraImage) {
    try {
      final int width = cameraImage.width;
      final int height = cameraImage.height;
      final img.Image image = img.Image(width: width, height: height);

      final yPlane = cameraImage.planes[0].bytes;
      final uPlane = cameraImage.planes[1].bytes;
      final vPlane = cameraImage.planes[2].bytes;

      final int uvRowStride = cameraImage.planes[1].bytesPerRow;
      final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int yIndex = y * width + x;
          final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

          final int yp = yPlane[yIndex];
          final int up = uPlane[uvIndex];
          final int vp = vPlane[uvIndex];

          int r = (yp + (1.370705 * (vp - 128))).toInt().clamp(0, 255);
          int g = (yp - (0.337633 * (up - 128)) - (0.698001 * (vp - 128)))
              .toInt()
              .clamp(0, 255);
          int b = (yp + (1.732446 * (up - 128))).toInt().clamp(0, 255);

          image.setPixelRgb(x, y, r, g, b);
        }
      }
      return image;
    } catch (e) {
      return null;
    }
  }

  String _formatLabel(dynamic label) {
    if (label == null || label == "Unknown Object") return "Detecting...";
    String l = label.toString().replaceAll('_', ' ');
    return l[0].toUpperCase() + l.substring(1);
  }

  DiseaseDetection _errorResult(String msg, {bool isLeaf = false}) {
    return DiseaseDetection(
      diseaseName: msg,
      confidence: 0.0,
      classIndex: -1,
      isValidLeaf: isLeaf,
    );
  }

  void dispose() {}
}
