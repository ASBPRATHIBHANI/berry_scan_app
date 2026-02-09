import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/aws_auth_service.dart'; // ✅ Use AWS Service
import '../services/language_service.dart';
import 'login_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  // In AWS context:
  // userId = Email
  // secret = Confirmation Code
  final String userId;
  final String secret;

  const NewPasswordScreen({
    super.key,
    required this.userId,
    required this.secret,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final AwsAuthService _authService = AwsAuthService(); // ✅ AWS Instance
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    final language = Provider.of<LanguageService>(context, listen: false);
    String newPass = _newPassController.text.trim();
    String confirmPass = _confirmPassController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      _showSnackBar("Please fill all fields", Colors.red);
      return;
    }

    if (newPass != confirmPass) {
      _showSnackBar(language.getText('pass_mismatch'), Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    // ✅ Call AWS to finalize the reset
    // We map 'userId' to Email and 'secret' to Code
    bool success = await _authService.confirmPasswordReset(
      widget.userId, // Email
      newPass, // New Password
      widget.secret, // Code from Deep Link
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password Reset Successful! Please Login."),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ Navigate back to Login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } else {
      _showSnackBar(language.getText('update_failed'), Colors.red);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageService>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Reset Password",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // No back button
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create a new password for your account.",
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14.sp),
              ),
              SizedBox(height: 30.h),

              // New Password Field
              Text(
                language.getText('new_pass'),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _newPassController,
                obscureText: true,
                decoration: _inputDecoration("Enter new password"),
              ),

              SizedBox(height: 20.h),

              // Confirm Password Field
              Text(
                language.getText('confirm_pass'),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _confirmPassController,
                obscureText: true,
                decoration: _inputDecoration("Confirm new password"),
              ),

              const Spacer(),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A6B4E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Set New Password",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.all(16.w),
    );
  }
}
