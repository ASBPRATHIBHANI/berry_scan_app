import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Services & Screens
import '../services/language_service.dart';
import 'signup_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  // 1. Available languages
  final List<String> _languages = ['English', 'සිංහල', 'தமிழ்'];

  // 2. Selected language (Default: English)
  String _selectedLanguage = 'English';

  final Color primaryGreen = const Color(0xFF3A6B4E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen, // Full green background
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header Logo ---
              RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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

              SizedBox(height: 100.h),

              // --- Center Content ---
              Center(
                child: Column(
                  children: [
                    Text(
                      'Select your language',
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // --- LANGUAGE DROPDOWN ---
                    Container(
                      width: 280.w,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedLanguage,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black,
                            size: 24.sp,
                          ),
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          items: _languages.map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedLanguage = newValue!;
                            });
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // --- CONTINUE BUTTON ---
                    SizedBox(
                      width: 280.w,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _saveAndContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Footer Text
              Center(
                child: Text(
                  'By clicking continue, you agree to our Terms of Service\nand Privacy Policy',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  // --- LOGIC TO SAVE LANGUAGE & NAVIGATE ---
  void _saveAndContinue() {
    // 1. Map selection to language code (en, si, ta)
    String code = 'en';
    if (_selectedLanguage == 'සිංහල') {
      code = 'si';
    } else if (_selectedLanguage == 'தமிழ்') {
      code = 'ta';
    }

    // 2. Save using the LanguageService (Provider)
    Provider.of<LanguageService>(context, listen: false).changeLanguage(code);

    debugPrint("Language saved: $code");

    // 3. Navigate to Sign Up
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  }
}
