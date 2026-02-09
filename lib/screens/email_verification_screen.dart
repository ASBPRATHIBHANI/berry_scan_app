import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String?
  signupToken; // ✅ Received from SignupScreen for internal DB sync

  const EmailVerificationScreen({
    super.key,
    required this.email,
    this.signupToken,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // =========================================================
  // 📝 VERIFY CODE (AMPLIFY & MYSQL SYNC)
  // =========================================================
  void _verifyCode() async {
    String code = _codeController.text.trim();

    if (code.length < 6) {
      _showSnackBar("Please enter the full 6-digit code", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // --- STEP 1: Confirm with AWS Amplify (Cognito) ---
      final result = await Amplify.Auth.confirmSignUp(
        username: widget.email,
        confirmationCode: code,
      );

      if (result.isSignUpComplete) {
        // --- STEP 2: Optional Database Sync ---
        // You can notify your Lambda that this email is now officially verified in MySQL
        await _syncVerificationWithDatabase();

        if (mounted) {
          _showSnackBar("✅ Email Verified! Please Login.", Colors.green);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    } on AuthException catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(e.message, Colors.red);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("An unexpected error occurred.", Colors.red);
    }
  }

  // ✅ New method to update your MySQL status if needed
  Future<void> _syncVerificationWithDatabase() async {
    try {
      final String syncUrl =
          "https://fwwnjl71l1.execute-api.us-east-1.amazonaws.com/prod/verify-status";
      await http.post(
        Uri.parse(syncUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": widget.email, "status": "verified"}),
      );
    } catch (e) {
      debugPrint("DB Sync Error: $e");
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 80.sp,
                color: const Color(0xFF3A6B4E),
              ),
              SizedBox(height: 24.h),
              Text(
                'Verify your Email',
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Enter the 6-digit code sent to\n${widget.email}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey),
              ),
              SizedBox(height: 40.h),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  letterSpacing: 8,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "000000",
                  hintStyle: TextStyle(color: Colors.grey.shade300),
                  contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: Color(0xFF3A6B4E),
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A6B4E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Verify Code',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () async {
                  try {
                    await Amplify.Auth.resendSignUpCode(username: widget.email);
                    _showSnackBar(
                      "Code resent! Check your inbox.",
                      Colors.blue,
                    );
                  } catch (e) {
                    _showSnackBar("Error resending code.", Colors.red);
                  }
                },
                child: Text(
                  "Resend Code",
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
