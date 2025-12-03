import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/home_screen.dart';
import 'screens/login.dart';
import 'screens/subscription_screen.dart';
import 'screens/subscription_status_screen.dart';
import 'screens/user_timeline_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/consent_screen.dart';
import 'screens/mandate_approval_screen.dart';
import 'screens/upi_setup_screen.dart';
import 'services/localization_service.dart';
import 'services/api_service.dart';
import 'services/voice_alert_service.dart';
import 'services/device_info_service.dart';
import 'widgets/language_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize basic services that work immediately
  await LocalizationService.loadLanguage();
  await VoiceAlertService.initialize();
  await DeviceInfoService.updateLoginTimestamp();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    LocalizationService.loadLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlertPe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: LanguageWrapper(child: const AuthWrapper()),
      debugShowCheckedModeBanner: false,
      routes: {
        '/subscription': (context) => const SubscriptionScreen(),
        '/subscription-status': (context) => const SubscriptionStatusScreen(),
        '/user-timeline': (context) => const UserTimelineScreen(),
        '/language-selection': (context) => const LanguageSelectionScreen(),
        '/consent': (context) => const ConsentScreen(),
        '/mandate-approval': (context) => const MandateApprovalScreen(),
        '/upi-setup': (context) => UpiSetupScreen(
          userId: ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?['userId'] ?? '',
          planId: ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?['planId'] ?? '',
        ),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await ApiService.isLoggedIn();
      final userData = await ApiService.getCachedUserData();
      
      setState(() {
        _isLoggedIn = isLoggedIn && userData != null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If user already logged in, go directly to main home screen
    if (_isLoggedIn) {
      return HomeScreenMain();
    } else {
      // If not logged in, show login page
      return LoginScreen();
    }
  }
}