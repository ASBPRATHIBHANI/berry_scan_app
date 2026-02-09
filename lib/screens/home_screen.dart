import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:amplify_flutter/amplify_flutter.dart'; // ✅ AWS Import

// Import Services
import '../services/aws_auth_service.dart'; // ✅ Use AWS Service
import '../services/database_helper.dart';
import '../services/language_service.dart';

// Import Screens
import 'scan_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'contact_us_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Navigation Index (0 = Home)
  final int _selectedIndex = 0;
  final Color primaryGreen = const Color(0xFF3A6B4E);

  final AwsAuthService _authService = AwsAuthService(); // ✅ AWS Instance

  // State Variables
  String _userName = "Loading...";
  String? _profileImageUrl; // Null = use placeholder

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch Name & Profile Image from AWS
  Future<void> _fetchUserData() async {
    try {
      // 1. Get Current User
      final user = await _authService.getCurrentUser();

      if (user != null) {
        // 2. Fetch Attributes (To get the 'name')
        final attributes = await Amplify.Auth.fetchUserAttributes();
        String? name;

        for (var element in attributes) {
          if (element.userAttributeKey == AuthUserAttributeKey.name) {
            name = element.value;
          }
        }

        if (mounted) {
          setState(() {
            _userName = name ?? "BerryScan User";
            // TODO: Connect AWS S3 for profile images later.
            // For now, we leave _profileImageUrl null to show the placeholder.
          });
        }
      } else {
        // 3. Try SQLite (Local Fallback if offline/logged out)
        final localUser = await DatabaseHelper.instance.getLastUser();
        if (mounted) {
          if (localUser != null) {
            setState(() {
              _userName = "${localUser['firstName']} ${localUser['lastName']}";
            });
          } else {
            setState(() {
              _userName = "Guest";
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      if (mounted) {
        setState(() => _userName = "BerryScan User");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access Language Service
    final language = Provider.of<LanguageService>(context);

    return Scaffold(
      backgroundColor: Colors.white,

      // 1. SCROLLABLE BODY
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER LOGO
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

              SizedBox(height: 24.h),

              // PROFILE & SEARCH ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Profile Image
                      CircleAvatar(
                        radius: 24.r,
                        backgroundColor: Colors.grey.shade200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24.r),
                          child: _profileImageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: _profileImageUrl!,
                                  fit: BoxFit.cover,
                                  width: 48.r,
                                  height: 48.r,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      ),
                                )
                              : Image.asset(
                                  'assets/images/profile_placeholder.jpg',
                                  fit: BoxFit.cover,
                                  width: 48.r,
                                  height: 48.r,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      ),
                                ),
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // Greeting
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            language.getText('hello'),
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            _userName,
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Search Button
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.search, color: Colors.white, size: 24.sp),
                  ),
                ],
              ),

              SizedBox(height: 30.h),

              // BANNER IMAGE
              Container(
                width: double.infinity,
                height: 160.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: Colors.grey.shade200,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/banner_image.jpg'),
                    fit: BoxFit.cover,
                    alignment: Alignment(0.0, -0.5),
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // MENU GRID
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 1.1,
                children: [
                  _buildMenuCard(
                    title: language.getText('start_scan'),
                    icon: Icons.qr_code_scanner,
                    color: primaryGreen,
                    isPrimary: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ScanScreen()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    title: language.getText('settings'),
                    icon: Icons.person_outline,
                    color: primaryGreen,
                    isPrimary: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    title: language.getText('history'),
                    icon: Icons.history,
                    color: Colors.grey.shade200,
                    textColor: primaryGreen,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    title: language.getText('contact'),
                    icon: Icons.contact_support_outlined,
                    color: Colors.grey.shade200,
                    textColor: primaryGreen,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ContactUsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // 2. BOTTOM NAVIGATION BAR
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

  // --- Helpers ---
  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color color,
    Color textColor = Colors.white,
    bool isPrimary = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isPrimary ? color : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: isPrimary
                    ? null
                    : Border.all(color: primaryGreen, width: 1.5),
              ),
              child: Icon(icon, size: 28.sp, color: primaryGreen),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : const Color(0xFF3A6B4E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;

    String safeLabel = label.length > 10
        ? "${label.substring(0, 8)}..."
        : label;

    return GestureDetector(
      onTap: () {
        if (index == 0) return;
        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ScanScreen()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
            safeLabel,
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
