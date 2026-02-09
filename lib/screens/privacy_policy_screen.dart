import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Services
import '../services/language_service.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Access Language Service
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
          language.getText('privacy'), // "Privacy Policy"
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              language.getText(
                'privacy_title',
              ), // "Privacy Policy for BerryScan"
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3A6B4E),
              ),
            ),
            SizedBox(height: 12.h),

            // Dynamic Policy Text
            // We combine multiple keys to form the full document
            RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  height: 1.6,
                  color: Colors.grey[800],
                ),
                children: [
                  TextSpan(
                    text: "${language.getText('last_updated')}\n\n",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _buildSection(language, 'intro_title', 'intro_text'),
                  _buildSection(language, 'data_title', 'data_text'),
                  _buildSection(language, 'use_title', 'use_text'),
                  _buildSection(language, 'sec_title', 'sec_text'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build sections (Title + Text + Newlines)
  TextSpan _buildSection(
    LanguageService language,
    String titleKey,
    String textKey,
  ) {
    return TextSpan(
      children: [
        TextSpan(
          text: "${language.getText(titleKey)}\n",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        TextSpan(text: "${language.getText(textKey)}\n\n"),
      ],
    );
  }
}
