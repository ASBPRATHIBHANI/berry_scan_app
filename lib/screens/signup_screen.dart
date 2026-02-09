import 'dart:convert'; // Required for JSON encoding
import 'package:http/http.dart' as http; // Required for Lambda API calls
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

// Services
import '../services/language_service.dart';

// Screens
import 'login_screen.dart';
import 'email_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final Color primaryGreen = const Color(0xFF3A6B4E);
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // =========================================================
  // 📝 HANDLE REGISTRATION (HYBRID: MYSQL & AWS AMPLIFY)
  // =========================================================
  Future<void> _handleRegister() async {
    final language = Provider.of<LanguageService>(context, listen: false);

    String first = _firstNameController.text.trim();
    String last = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String pass = _passwordController.text.trim();
    String confirm = _confirmPasswordController.text.trim();

    // --- 1. Basic Validation ---
    if (first.isEmpty || last.isEmpty || email.isEmpty || pass.isEmpty) {
      _showSnackBar(language.getText('fill_all_fields'), Colors.red);
      return;
    }

    if (pass.length < 8) {
      _showSnackBar(language.getText('password_too_short'), Colors.red);
      return;
    }

    if (pass != confirm) {
      _showSnackBar(language.getText('passwords_do_not_match'), Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // --- STEP A: CALL AWS LAMBDA (MYSQL REGISTRATION) ---
      // This saves the user details into your RDS User table
      final String registerUrl =
          "https://fwwnjl71l1.execute-api.us-east-1.amazonaws.com/prod/register";

      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "first_name": first,
          "last_name": last,
          "email": email,
          "password": pass,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // --- STEP B: CALL AWS AMPLIFY (COGNITO SIGNUP) ---
        // This triggers the verification email from Cognito
        final userAttributes = {
          AuthUserAttributeKey.email: email,
          AuthUserAttributeKey.name: "$first $last",
        };

        final result = await Amplify.Auth.signUp(
          username: email,
          password: pass,
          options: SignUpOptions(userAttributes: userAttributes),
        );

        setState(() => _isLoading = false);

        if (result.isSignUpComplete) {
          _showSnackBar(language.getText('signup_success'), Colors.green);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        } else {
          // RESTORED: Passing email and signupToken to the Verification Screen
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => EmailVerificationScreen(
                  email: email,
                  signupToken: responseData['token'] ?? "", // Token from MySQL
                ),
              ),
            );
          }
        }
      } else {
        setState(() => _isLoading = false);
        _showSnackBar(
          responseData['message'] ?? "Registration failed",
          Colors.red,
        );
      }
    } on AuthException catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(e.message, Colors.red);
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Signup Error: $e");
      _showSnackBar(
        "An unexpected error occurred. Please try again.",
        Colors.red,
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
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
              RichText(
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
              SizedBox(height: 20.h),
              Center(
                child: Column(
                  children: [
                    Text(
                      language.getText('create_account'),
                      style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      language.getText('enter_details'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              _buildInput(
                language.getText('first_name'),
                "First Name",
                Icons.person_outline,
                _firstNameController,
              ),
              SizedBox(height: 16.h),
              _buildInput(
                language.getText('last_name'),
                "Last Name",
                Icons.person_outline,
                _lastNameController,
              ),
              SizedBox(height: 16.h),
              _buildInput(
                language.getText('email'),
                "Email@Domain.Com",
                Icons.email_outlined,
                _emailController,
              ),
              SizedBox(height: 16.h),
              _buildInput(
                language.getText('password'),
                "Password",
                Icons.lock_outline,
                _passwordController,
                isPassword: true,
              ),
              SizedBox(height: 16.h),
              _buildInput(
                language.getText('confirm_pass'),
                "Confirm Password",
                Icons.lock_outline,
                _confirmPasswordController,
                isPassword: true,
              ),
              SizedBox(height: 30.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          language.getText('register'),
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 40.h),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                    children: [
                      const TextSpan(
                        text: "By clicking continue, you agree to our ",
                      ),
                      TextSpan(
                        text: "Terms of Service",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const TextSpan(text: " and\n"),
                      TextSpan(
                        text: "Privacy Policy",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey, size: 20.sp),
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              fontSize: 14.sp,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
            isDense: true,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryGreen),
            ),
          ),
        ),
      ],
    );
  }
}
