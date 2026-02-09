import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/aws_auth_service.dart';
import 'login_screen.dart';

class ConfirmCodeScreen extends StatefulWidget {
  final String email;
  const ConfirmCodeScreen({super.key, required this.email});

  @override
  State<ConfirmCodeScreen> createState() => _ConfirmCodeScreenState();
}

class _ConfirmCodeScreenState extends State<ConfirmCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final AwsAuthService _authService = AwsAuthService();
  bool _isLoading = false;

  void _verify() async {
    setState(() => _isLoading = true);

    // Call AWS to confirm code
    bool success = await _authService.confirmEmail(
      widget.email,
      _codeController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Email Verified! Please Login.")),
      );
      // Go to Login Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Invalid Code. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Verify Email",
              style: GoogleFonts.poppins(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "Enter the code sent to ${widget.email}",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(height: 30.h),

            // Code Input
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Confirmation Code",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Verify Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A6B4E),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Verify",
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
