import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Services
import '../services/aws_auth_service.dart'; // ✅ Changed to AWS
import '../services/language_service.dart';

// Screens
import 'home_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart'; // Note: You will need to update this file next

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Services
  final AwsAuthService _authService = AwsAuthService(); // ✅ Use AWS Service

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final Color primaryGreen = const Color(0xFF3A6B4E);
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =========================================================
  // ☁️ OPTION 1: LOGIN WITH AWS COGNITO (Email/Pass)
  // =========================================================
  void _handleLogin() async {
    String email = _emailController.text.trim();
    String pass = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showSnackBar("Please enter email and password", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    // ✅ Call AWS Login
    // The service returns "success" or an error message string
    String? result = await _authService.login(email, pass);

    setState(() => _isLoading = false);

    if (result == "success") {
      if (mounted) {
        // Go to Home Screen on success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      // Show specific AWS error (e.g., "User not confirmed", "Incorrect password")
      _showSnackBar(result ?? "Login Failed", Colors.red);
    }
  }

  // =========================================================
  // ☁️ OPTION 2: LOGIN WITH GOOGLE (Placeholder)
  // =========================================================
  void _handleGoogleLogin() {
    // Social Sign-in requires "Federated Identities" setup in AWS.
    // Keeping this as a placeholder for stability.
    _showSnackBar("Google Login is coming soon!", Colors.orange);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    // Access Language Service
    final language = Provider.of<LanguageService>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Logo ---
              Center(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 32.sp,
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
              ),
              SizedBox(height: 40.h),

              // --- Title (Translated) ---
              Center(
                child: Column(
                  children: [
                    Text(
                      language.getText('sign_in_title'),
                      style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      language.getText('sign_in_desc'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),

              // --- INPUT FIELDS ---
              _buildLabel(language.getText('email')),
              SizedBox(height: 8.h),
              TextField(
                controller: _emailController,
                decoration: _inputDecoration(
                  language.getText('email'),
                  Icons.email_outlined,
                ),
              ),

              SizedBox(height: 24.h),

              _buildLabel(language.getText('password')),
              SizedBox(height: 8.h),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: _inputDecoration(
                  language.getText('password'),
                  Icons.lock_outline,
                ),
              ),

              SizedBox(height: 12.h),

              // Forgot Password Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Navigate to Forgot Password Screen
                    // Note: Ensure forgot_password_screen.dart is also updated for AWS later
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    language.getText('forgot_pass'),
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // --- LOGIN BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          language.getText('login'),
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 20.h),

              // --- OR DIVIDER ---
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      language.getText('or'),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),

              SizedBox(height: 20.h),

              // --- GOOGLE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: OutlinedButton.icon(
                  onPressed: _handleGoogleLogin,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  icon: Image.asset('assets/images/google.png', width: 24.w),
                  label: Text(
                    language.getText('continue_google'),
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // --- SIGNUP LINK ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${language.getText('dont_have_acc')} ",
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14.sp,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                    child: Text(
                      language.getText('signup'),
                      style: GoogleFonts.poppins(
                        color: primaryGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  // Helpers
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey, size: 22.sp),
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: Colors.grey.shade400,
        fontSize: 14.sp,
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16.h),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: primaryGreen),
      ),
    );
  }
}
