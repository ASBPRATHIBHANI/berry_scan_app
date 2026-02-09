import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService with ChangeNotifier {
  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language_code') ?? 'en';
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    _currentLanguage = languageCode;
    notifyListeners();
  }

  // ✅ COMPLETE DICTIONARY
  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Auth
      'signup': 'Sign Up',
      'login': 'Log In',
      'create_account': 'Create an account',
      'enter_details': 'Enter your details to sign up',
      'first_name': 'First Name',
      'last_name': 'Last Name',
      'email': 'Email',
      'password': 'Password',
      'confirm_pass': 'Confirm Password',
      'register': 'Register',
      'or': 'or',
      'continue_google': 'Continue with Google',
      'terms': 'By clicking continue, you agree to our Terms...',
      'sign_in_title': 'Sign in',
      'sign_in_desc': 'Enter your email & password to sign in',
      'dont_have_acc': "Don't have an account?",
      'already_have_acc': 'Already have an account?',
      'forgot_pass': 'Forgot Password?',

      // Home & Nav
      'hello': 'Hello, Welcome back!',
      'start_scan': 'Start Scan',
      'settings': 'Settings',
      'history': 'History', // Shortened for nav bar
      'view_history': 'View History',
      'contact': 'Contact Us',
      'home': 'Home',
      'scan': 'Scan',
      'logout': 'Log Out',

      // Settings
      'general': 'General',
      'security': 'Security',
      'language': 'Language',
      'change_pass': 'Change Password',
      'privacy': 'Privacy Policy',
      'biometric': 'Biometric',
      'choose_data': 'Choose what data you share with us',
      'profile_updated': 'Profile Updated!',
      'upload_failed': 'Upload failed.',

      // Scan Screen
      'scan_title': 'Real-Time Scan',
      'ready_scan': 'Ready to scan...',
      'point_leaf': 'Point at a leaf...',
      'camera_scan': 'Start Camera Scan',
      'get_advice': 'Get Treatment Advice',
      'no_cure_db': 'No cure found in Database',
      'please_start_camera': "Please tap 'Start Camera Scan' first!",
      'detected': 'Detected:',

      // Result Screen
      'treatment_advice': 'Treatment Advice',
      'accuracy': 'Accuracy',
      'organic_cure': 'Organic Cure',
      'chemical_cure': 'Chemical Cure',
      'no_data': 'No data',

      // Change Password
      'old_pass': 'Old Password',
      'new_pass': 'New Password',
      'update_pass': 'Update Password',
      'fill_fields': 'Please fill in all fields',
      'pass_mismatch': 'Passwords do not match',
      'pass_short': 'Password must be at least 8 characters',
      'pass_updated': 'Password updated successfully!',
      'update_failed': 'Failed to update. Check your old password.',

      // Contact Us
      'we_help': "We're here to help!",
      'fill_form': "Fill out the form below and we will get back to you soon.",
      'subject': 'Subject',
      'message': 'Message',
      'send_msg': 'Send Message',
      'msg_sent': 'Message Sent!',
      'app_issue': 'e.g., App Issue',
      'type_message': 'Type your message here...',

      // History
      'scan_history': 'Scan History',
      'no_scans': 'No scans yet. Start scanning!',
      'unknown_date': 'Unknown Date',

      // Privacy Policy
      'privacy_title': 'Privacy Policy for BerryScan',
      'last_updated': 'Last updated: December 2025',
      'intro_title': '1. Introduction',
      'intro_text':
          'Welcome to BerryScan. We value your privacy and are committed to protecting your personal data.',
      'data_title': '2. Data We Collect',
      'data_text':
          'We collect images you upload for disease analysis and basic profile information (name, email) to manage your account.',
      'use_title': '3. How We Use Your Data',
      'use_text':
          'Your data is used solely to provide disease detection services and improve our AI model accuracy.',
      'sec_title': '4. Data Security',
      'sec_text':
          'We implement security measures to ensure your data is safe within our Appwrite database.',
    },
    'si': {
      // Auth
      'signup': 'ලියාපදිංචි වන්න',
      'login': 'ඇතුල් වන්න',
      'create_account': 'ගිණුමක් සාදන්න',
      'enter_details': 'ලියාපදිංචි වීමට විස්තර ඇතුළත් කරන්න',
      'first_name': 'මුල් නම',
      'last_name': 'වාසගම',
      'email': 'විද්‍යුත් තැපෑල',
      'password': 'මුරපදය',
      'confirm_pass': 'මුරපදය තහවුරු කරන්න',
      'register': 'ලියාපදිංචි වන්න',
      'or': 'හෝ',
      'continue_google': 'Google සමඟ ඉදිරියට යන්න',
      'terms': 'ඉදිරියට යාමෙන් ඔබ අපගේ කොන්දේසිවලට එකඟ වේ...',
      'sign_in_title': 'ඇතුල් වන්න',
      'sign_in_desc': 'ඔබගේ විද්‍යුත් තැපෑල සහ මුරපදය ඇතුළත් කරන්න',
      'dont_have_acc': "ගිණුමක් නොමැතිද?",
      'already_have_acc': 'දැනටමත් ගිණුමක් තිබේද?',
      'forgot_pass': 'මුරපදය අමතකද?',

      // Home & Nav
      'hello': 'ආයුබෝවන්, සාදරයෙන් පිළිගනිමු!',
      'start_scan': 'ස්කෑන් කරන්න',
      'settings': 'සැකසුම්',
      'history': 'ඉතිහාසය',
      'view_history': 'ඉතිහාසය බලන්න',
      'contact': 'අප අමතන්න',
      'home': 'මුල් පිටුව',
      'scan': 'ස්කෑන්',
      'logout': 'ඉවත් වන්න',

      // Settings
      'general': 'සාමාන්‍ය',
      'security': 'ආරක්ෂාව',
      'language': 'භාෂාව',
      'change_pass': 'මුරපදය වෙනස් කරන්න',
      'privacy': 'රහස්‍යතා ප්‍රතිපත්තිය',
      'biometric': 'ජෛවමිතික',
      'choose_data': 'ඔබ බෙදාගන්නා දත්ත තෝරන්න',
      'profile_updated': 'පැතිකඩ යාවත්කාලීන කරන ලදි!',
      'upload_failed': 'උඩුගත කිරීම අසාර්ථක විය.',

      // Scan Screen
      'scan_title': 'තථ්ය කාලීන ස්කෑන්',
      'ready_scan': 'ස්කෑන් කිරීමට සූදානම්...',
      'point_leaf': 'කොළයක් දෙසට යොමු කරන්න...',
      'camera_scan': 'කැමරා ස්කෑන් අරඹන්න',
      'get_advice': 'ප්‍රතිකාර උපදෙස් ලබා ගන්න',
      'no_cure_db': 'දත්ත ගබඩාවේ ප්‍රතිකාරයක් හමු නොවීය',
      'please_start_camera': "කරුණාකර පළමුව 'කැමරා ස්කෑන් අරඹන්න' තට්ටු කරන්න!",
      'detected': 'හඳුනාගත්:',

      // Result Screen
      'treatment_advice': 'ප්‍රතිකාර උපදෙස්',
      'accuracy': 'නිරවද්‍යතාව',
      'organic_cure': 'කාබනික ප්‍රතිකාර',
      'chemical_cure': 'රසායනික ප්‍රතිකාර',
      'no_data': 'දත්ත නැත',

      // Change Password
      'old_pass': 'පැරණි මුරපදය',
      'new_pass': 'නව මුරපදය',
      'update_pass': 'මුරපදය යාවත්කාලීන කරන්න',
      'fill_fields': 'කරුණාකර සියලුම කොටස් පුරවන්න',
      'pass_mismatch': 'මුරපද නොගැලපේ',
      'pass_short': 'මුරපදය අවම වශයෙන් අක්ෂර 8 ක් විය යුතුය',
      'pass_updated': 'මුරපදය සාර්ථකව යාවත්කාලීන කරන ලදි!',
      'update_failed':
          'යාවත්කාලීන කිරීම අසාර්ථක විය. පැරණි මුරපදය පරීක්ෂා කරන්න.',

      // Contact Us
      'we_help': 'අපි ඔබට උදව් කිරීමට සූදානම්!',
      'fill_form': "පහත පෝරමය පුරවන්න, අපි ඉක්මනින් ඔබ හා සම්බන්ධ වන්නෙමු.",
      'subject': 'මාතෘකාව',
      'message': 'පණිවිඩය',
      'send_msg': 'පණිවිඩය යවන්න',
      'msg_sent': 'පණිවිඩය යවන ලදි!',
      'app_issue': 'උදා: යෙදුම් ගැටළුව',
      'type_message': 'ඔබගේ පණිවිඩය මෙහි ටයිප් කරන්න...',

      // History
      'scan_history': 'ස්කෑන් ඉතිහාසය',
      'no_scans': 'තවම ස්කෑන් කර නැත. ස්කෑන් කිරීම අරඹන්න!',
      'unknown_date': 'නොදන්නා දිනයක්',

      // Privacy Policy
      'privacy_title': 'BerryScan සඳහා රහස්‍යතා ප්‍රතිපත්තිය',
      'last_updated': 'අවසන් වරට යාවත්කාලීන කළේ: 2025 දෙසැම්බර්',
      'intro_title': '1. හැඳින්වීම',
      'intro_text':
          'BerryScan වෙත සාදරයෙන් පිළිගනිමු. අපි ඔබේ පෞද්ගලිකත්වය අගය කරන අතර ඔබේ පුද්ගලික දත්ත ආරක්ෂා කිරීමට කැපවී සිටිමු.',
      'data_title': '2. අපි එකතු කරන දත්ත',
      'data_text':
          'රෝග විනිශ්චය සඳහා ඔබ උඩුගත කරන පින්තූර සහ ගිණුම කළමනාකරණය සඳහා මූලික තොරතුරු (නම, විද්‍යුත් තැපෑල) අපි රැස් කරමු.',
      'use_title': '3. අපි ඔබේ දත්ත භාවිතා කරන ආකාරය',
      'use_text':
          'ඔබේ දත්ත රෝග හඳුනාගැනීමේ සේවා සැපයීමට සහ අපගේ AI ආකෘතිය වැඩිදියුණු කිරීමට පමණක් භාවිතා වේ.',
      'sec_title': '4. දත්ත ආරක්ෂාව',
      'sec_text':
          'Appwrite දත්ත ගබඩාව තුළ ඔබේ දත්ත ආරක්ෂිතව තබා ගැනීමට අපි ආරක්ෂක පියවර ක්‍රියාත්මක කරමු.',
    },
    'ta': {
      // Auth
      'signup': 'பதிவு சேர்',
      'login': 'உள்நுழைய',
      'create_account': 'கணக்கை உருவாக்கவும்',
      'enter_details': 'பதிவு செய்ய விவரங்களை உள்ளிடவும்',
      'first_name': 'முதல் பெயர்',
      'last_name': 'கடைசி பெயர்',
      'email': 'மின்னஞ்சல்',
      'password': 'கடவுச்சொல்',
      'confirm_pass': 'கடவுச்சொல்லை உறுதிசெய்',
      'register': 'பதிவு',
      'or': 'அல்லது',
      'continue_google': 'Google உடன் தொடரவும்',
      'terms': 'தொடர்வதன் மூலம் விதிமுறைகளை ஏற்கிறீர்கள்...',
      'sign_in_title': 'உள்நுழைய',
      'sign_in_desc': 'மின்னஞ்சல் மற்றும் கடவுச்சொல்லை உள்ளிடவும்',
      'dont_have_acc': "கணக்கு இல்லையா?",
      'already_have_acc': 'ஏற்கனவே கணக்கு உள்ளதா?',
      'forgot_pass': 'கடவுச்சொல் மறந்ததா?',

      // Home & Nav
      'hello': 'வணக்கம், வருக!',
      'start_scan': 'ஸ்கேன் செய்',
      'settings': 'அமைப்புகள்',
      'history': 'வரலாறு',
      'view_history': 'வரலாற்றைப் பார்க்கவும்',
      'contact': 'தொடர்புக்கு',
      'home': 'முகப்பு',
      'scan': 'ஸ்கேன்',
      'logout': 'வெளியேறு',

      // Settings
      'general': 'பொது',
      'security': 'பாதுகாப்பு',
      'language': 'மொழி',
      'change_pass': 'கடவுச்சொல் மாற்றம்',
      'privacy': 'தனியுரிமை',
      'biometric': 'பயோமெட்ரிக்',
      'choose_data': 'நீங்கள் பகிரும் தரவைத் தேர்வுசெய்யவும்',
      'profile_updated': 'சுயவிவரம் புதுப்பிக்கப்பட்டது!',
      'upload_failed': 'பதிவேற்றம் தோல்வியடைந்தது.',

      // Scan Screen
      'scan_title': 'நிகழ்நேர ஸ்கேன்',
      'ready_scan': 'ஸ்கேன் செய்ய தயார்...',
      'point_leaf': 'இலையை நோக்கி காட்டுங்கள்...',
      'camera_scan': 'கேமரா ஸ்கேன் தொடங்கவும்',
      'get_advice': 'சிகிச்சை ஆலோசனை பெறவும்',
      'no_cure_db': 'தரவுத்தளத்தில் தீர்வு இல்லை',
      'please_start_camera': "முதலில் 'கேமரா ஸ்கேன்' தொடங்கவும்!",
      'detected': 'கண்டறியப்பட்டது:',

      // Result Screen
      'treatment_advice': 'சிகிச்சை ஆலோசனை',
      'accuracy': 'துல்லியம்',
      'organic_cure': 'இயற்கை தீர்வு',
      'chemical_cure': 'ரசாயன தீர்வு',
      'no_data': 'தரவு இல்லை',

      // Change Password
      'old_pass': 'பழைய கடவுச்சொல்',
      'new_pass': 'புதிய கடவுச்சொல்',
      'update_pass': 'புதுப்பிக்கவும்',
      'fill_fields': 'எல்லா புலங்களையும் நிரப்பவும்',
      'pass_mismatch': 'கடவுச்சொற்கள் பொருந்தவில்லை',
      'pass_short': 'கடவுச்சொல் குறைந்தது 8 எழுத்துக்கள் இருக்க வேண்டும்',
      'pass_updated': 'கடவுச்சொல் புதுப்பிக்கப்பட்டது!',
      'update_failed': 'தோல்வி. பழைய கடவுச்சொல்லைச் சரிபார்க்கவும்.',

      // Contact Us
      'we_help': 'நாங்கள் உதவ இருக்கிறோம்!',
      'fill_form': "கீழே உள்ள படிவத்தை நிரப்பவும், விரைவில் தொடர்புகொள்வோம்.",
      'subject': 'தலைப்பு',
      'message': 'செய்தி',
      'send_msg': 'அனுப்பவும்',
      'msg_sent': 'செய்தி அனுப்பப்பட்டது!',
      'app_issue': 'எ.கா., செயலி சிக்கல்',
      'type_message': 'உங்கள் செய்தியை இங்கே தட்டச்சு செய்யவும்...',

      // History
      'scan_history': 'ஸ்கேன் வரலாறு',
      'no_scans': 'ஸ்கேன் இல்லை. ஸ்கேன் செய்யத் தொடங்குங்கள்!',
      'unknown_date': 'தெரியாத தேதி',

      // Privacy Policy
      'privacy_title': 'BerryScan தனியுரிமைக் கொள்கை',
      'last_updated': 'கடைசியாக புதுப்பிக்கப்பட்டது: டிசம்பர் 2025',
      'intro_title': '1. அறிமுகம்',
      'intro_text':
          'BerryScan-க்கு வரவேற்கிறோம். உங்கள் தனியுரிமையை நாங்கள் மதிக்கிறோம்.',
      'data_title': '2. நாங்கள் சேகரிக்கும் தரவு',
      'data_text':
          'நோய் பகுப்பாய்விற்காக நீங்கள் பதிவேற்றும் படங்கள் மற்றும் அடிப்படை சுயவிவரத் தகவல்களை நாங்கள் சேகரிக்கிறோம்.',
      'use_title': '3. உங்கள் தரவை நாங்கள் எவ்வாறு பயன்படுத்துகிறோம்',
      'use_text':
          'நோய் கண்டறிதல் சேவைகளை வழங்கவும் எங்கள் AI மாதிரியை மேம்படுத்தவும் மட்டுமே உங்கள் தரவு பயன்படுத்தப்படுகிறது.',
      'sec_title': '4. தரவு பாதுகாப்பு',
      'sec_text':
          'எங்கள் Appwrite தரவுத்தளத்தில் உங்கள் தரவு பாதுகாப்பாக இருப்பதை உறுதிசெய்ய பாதுகாப்பு நடவடிக்கைகளை நாங்கள் செயல்படுத்துகிறோம்.',
    },
  };

  String getText(String key) {
    return _localizedValues[_currentLanguage]?[key] ?? key;
  }
}
