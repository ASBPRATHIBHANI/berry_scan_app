import 'dart:async'; // Required for StreamSubscription
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart'; // Import app_links for Deep Linking

// AWS Amplify Imports
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart'; // ✅ Import API Plugin
import 'amplifyconfiguration.dart';
import 'models/ModelProvider.dart'; // ✅ Import Generated Models

// Services
import 'services/aws_auth_service.dart';
import 'services/language_service.dart';

// Screens
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/new_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize AWS Amplify (Auth + API)
  await _configureAmplify();

  // 2. Load saved language preference
  final languageService = LanguageService();
  await languageService.loadLanguage();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => languageService)],
      child: const BerryScanApp(),
    ),
  );
}

// ✅ UPDATED CONFIGURATION FOR AMPLIFY v2.9.0+
Future<void> _configureAmplify() async {
  try {
    // 1. Create the Auth Plugin
    final auth = AmplifyAuthCognito();

    // 2. Create the API Plugin
    // ⚠️ CRITICAL FIX: In version 2.9.0+, we must wrap the ModelProvider
    // inside 'APIPluginOptions'.
    final api = AmplifyAPI(
      options: APIPluginOptions(modelProvider: ModelProvider.instance),
    );

    // 3. Add BOTH plugins
    await Amplify.addPlugins([auth, api]);

    // 4. Initialize Amplify
    await Amplify.configure(amplifyconfig);
    print("✅ AWS Amplify Configured Successfully (Database Enabled)");
  } on AmplifyAlreadyConfiguredException {
    print("⚠️ Amplify was already configured. Skipping...");
  } on Exception catch (e) {
    print("❌ Error configuring Amplify: $e");
  }
}

class BerryScanApp extends StatefulWidget {
  const BerryScanApp({super.key});

  @override
  State<BerryScanApp> createState() => _BerryScanAppState();
}

class _BerryScanAppState extends State<BerryScanApp> {
  // 1. SERVICES & STATE
  final AwsAuthService _authService = AwsAuthService();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  // 2. DEEP LINKING VARIABLES
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check if user is already logged in
    _initDeepLinkListener(); // Start listening for Email Links
  }

  // --- A. AUTO-LOGIN LOGIC (AWS) ---
  Future<void> _checkLoginStatus() async {
    try {
      // Get current user from AWS
      final user = await _authService.getCurrentUser();

      if (mounted) {
        setState(() {
          _isLoggedIn = user != null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Auto-login check failed: $e");
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  // --- B. DEEP LINK LISTENER ---
  void _initDeepLinkListener() {
    _appLinks = AppLinks();

    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      },
      onError: (err) {
        debugPrint("Deep Link Error: $err");
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    print("🔗 Deep Link Received: $uri");

    // Example logic for BerryScan deep links (Password Reset)
    if (uri.scheme == 'berryscan' && uri.path.contains('reset')) {
      String? userId = uri.queryParameters['userId'];
      String? secret = uri.queryParameters['secret'];

      if (userId != null && secret != null) {
        print("✅ Valid Reset Link! Navigating...");

        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => NewPasswordScreen(userId: userId, secret: secret),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: _navigatorKey, // ✅ Attach Key Here
          debugShowCheckedModeBanner: false,
          title: 'BerryScan',
          theme: ThemeData(
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
          ),
          // Show Spinner -> Home -> or Welcome
          home: _isLoading
              ? const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFF3A6B4E)),
                  ),
                )
              : (_isLoggedIn ? const HomeScreen() : const WelcomeScreen()),
        );
      },
    );
  }
}
