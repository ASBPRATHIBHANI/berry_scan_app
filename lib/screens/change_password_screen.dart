import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:amplify_flutter/amplify_flutter.dart'; // ✅ Import Amplify

import '../services/language_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final language = Provider.of<LanguageService>(context, listen: false);

    String oldPass = _oldPasswordController.text.trim();
    String newPass = _newPasswordController.text.trim();
    String confirmPass = _confirmPasswordController.text.trim();

    // 1. Basic Validation
    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showMessage(language.getText('fill_fields'), Colors.red);
      return;
    }

    if (newPass != confirmPass) {
      _showMessage(language.getText('pass_mismatch'), Colors.red);
      return;
    }

    if (newPass.length < 8) {
      _showMessage(language.getText('pass_short'), Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ 2. Call AWS Amplify to Update Password
      await Amplify.Auth.updatePassword(
        oldPassword: oldPass,
        newPassword: newPass,
      );

      setState(() => _isLoading = false);

      // Success
      if (mounted) {
        _showMessage(language.getText('pass_updated'), Colors.green);
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      setState(() => _isLoading = false);
      // Failure (e.g., Wrong old password)
      _showMessage(e.message, Colors.red);
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage("An error occurred", Colors.red);
    }
  }

  void _showMessage(String msg, Color color) {
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
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          language.getText('change_pass'), // "Change Password"
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            children: [
              _buildPasswordField(
                language.getText('old_pass'),
                _oldPasswordController,
              ),
              SizedBox(height: 20.h),
              _buildPasswordField(
                language.getText('new_pass'),
                _newPasswordController,
              ),
              SizedBox(height: 20.h),
              _buildPasswordField(
                language.getText('confirm_pass'),
                _confirmPasswordController,
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A6B4E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          language.getText('update_pass'), // "Update Password"
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

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.all(16.w),
          ),
        ),
      ],
    );
  }
}
