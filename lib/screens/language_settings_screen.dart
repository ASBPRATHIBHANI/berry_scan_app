import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch language changes to update UI instantly
    final languageService = Provider.of<LanguageService>(context);
    final currentCode = languageService.currentLanguage;

    // Helper to map code to display name
    String getLanguageName(String code) {
      if (code == 'si') return 'Sinhala';
      if (code == 'ta') return 'Tamil';
      return 'English';
    }

    final List<String> languages = ['English', 'Sinhala', 'Tamil'];

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
          languageService.getText('language'), // ✅ Auto-translates header
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
            children: languages.map((lang) {
              bool isSelected = getLanguageName(currentCode) == lang;
              return _buildLanguageOption(context, lang, isSelected);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String language,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        // 1. Map Name -> Code
        String code = 'en';
        if (language == 'Sinhala') code = 'si';
        if (language == 'Tamil') code = 'ta';

        // 2. Change Language (Updates the whole app)
        Provider.of<LanguageService>(
          context,
          listen: false,
        ).changeLanguage(code);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3A6B4E).withOpacity(0.1)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12.r),
          border: isSelected
              ? Border.all(color: const Color(0xFF3A6B4E))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF3A6B4E) : Colors.black,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: const Color(0xFF3A6B4E),
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }
}
