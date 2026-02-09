import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:amplify_flutter/amplify_flutter.dart'; // ✅ AWS Import

// ✅ Import Services
import '../services/aws_auth_service.dart'; // ✅ Use AWS Service
import '../services/database_helper.dart';
import '../services/language_service.dart';

// ✅ Import Navigation Screens
import 'home_screen.dart';
import 'scan_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'language_settings_screen.dart';
import 'contact_us_screen.dart';
import 'change_password_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 3 = Settings Tab
  final int _selectedIndex = 3;
  final Color primaryGreen = const Color(0xFF3A6B4E);

  // Services & State
  final AwsAuthService _authService = AwsAuthService(); // ✅ AWS Instance
  final ImagePicker _picker = ImagePicker();

  String _userName = "Loading...";
  String _userEmail = "User";
  String? _profileImageUrl; // Null = use placeholder
  bool _isBiometricEnabled = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // 1. Fetch User Data (Name, Email) from AWS
  Future<void> _fetchUserData() async {
    try {
      // 1. Get Current User
      final user = await _authService.getCurrentUser();

      if (user != null) {
        // 2. Fetch Attributes from AWS Cognito
        final attributes = await Amplify.Auth.fetchUserAttributes();
        String? name;
        String? email;

        for (var element in attributes) {
          if (element.userAttributeKey == AuthUserAttributeKey.name) {
            name = element.value;
          } else if (element.userAttributeKey == AuthUserAttributeKey.email) {
            email = element.value;
          }
        }

        if (mounted) {
          setState(() {
            _userName = name ?? "BerryScan User";
            _userEmail = email ?? "user@example.com";
            // Note: S3 Image fetching will be implemented later
          });
        }
      } else {
        // 3. Fallback to SQLite (Local)
        final localUser = await DatabaseHelper.instance.getLastUser();
        if (mounted) {
          if (localUser != null) {
            setState(() {
              _userName = "${localUser['firstName']} ${localUser['lastName']}";
              _userEmail = localUser['email'];
            });
          } else {
            setState(() => _userName = "Guest");
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }
  }

  // 2. Upload Profile Picture (Placeholder for AWS S3)
  Future<void> _pickAndUploadImage() async {
    // S3 Storage logic is distinct from Appwrite.
    // Keeping this safe for now to prevent crashes.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile upload coming soon with AWS S3!"),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // 3. Logout Logic (AWS)
  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      // Remove all routes and go to Login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Access Language Service
    final language = Provider.of<LanguageService>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 28.sp,
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

              SizedBox(height: 30.h),

              Center(
                child: Text(
                  language.getText('settings'),
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // --- Profile Section ---
              Row(
                children: [
                  // Clickable Profile Image
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 30.r,
                          backgroundColor: Colors.grey.shade200,
                          child: _isUploading
                              ? const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: CircularProgressIndicator(),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(30.r),
                                  child: _profileImageUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: _profileImageUrl!,
                                          fit: BoxFit.cover,
                                          width: 60.r,
                                          height: 60.r,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.person),
                                        )
                                      : Image.asset(
                                          'assets/images/profile_placeholder.jpg',
                                          fit: BoxFit.cover,
                                          width: 60.r,
                                          height: 60.r,
                                          errorBuilder:
                                              (context, error, stack) =>
                                                  const Icon(
                                                    Icons.person,
                                                    size: 40,
                                                    color: Colors.grey,
                                                  ),
                                        ),
                                ),
                        ),
                        // Edit Icon
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: const BoxDecoration(
                              color: Color(0xFF3A6B4E),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 10.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),

                  // Name & Email (Wrapped in Expanded to fix Overflow)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          _userEmail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edit Button (Visual)
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 20.sp,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40.h),

              // --- General Section ---
              _buildSectionTitle(language.getText('general')),
              _buildListTile(
                language.getText('language'),
                "English/සිංහල/தமிழ்",
                showArrow: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LanguageSettingsScreen(),
                    ),
                  );
                },
              ),
              _buildListTile(
                language.getText('contact'),
                "",
                showArrow: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                  );
                },
              ),

              SizedBox(height: 24.h),

              // --- Security Section ---
              _buildSectionTitle(language.getText('security')),
              _buildListTile(
                language.getText('change_pass'),
                "",
                showArrow: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              _buildListTile(
                language.getText('privacy'),
                "",
                showArrow: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),

              SizedBox(height: 24.h),

              // --- Data Section ---
              Text(
                language.getText('choose_data'),
                style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey),
              ),
              SizedBox(height: 12.h),

              // Biometric Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    language.getText('biometric'),
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Switch(
                    value: _isBiometricEnabled,
                    activeColor: primaryGreen,
                    onChanged: (value) {
                      setState(() {
                        _isBiometricEnabled = value;
                      });
                    },
                  ),
                ],
              ),

              SizedBox(height: 40.h),

              // --- Logout Button ---
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: Text(
                    language.getText('logout'),
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, language.getText('home'), 0),
            _buildNavItem(
              Icons.document_scanner_outlined,
              language.getText('scan'),
              1,
            ),
            _buildNavItem(
              Icons.pie_chart_outline,
              language.getText('history'),
              2,
            ),
            _buildNavItem(
              Icons.settings_outlined,
              language.getText('settings'),
              3,
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey),
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle, {
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey),
              ),
            if (showArrow) ...[
              SizedBox(width: 8.w),
              Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ScanScreen()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
            size: 24.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              color: isSelected ? Colors.blue : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
