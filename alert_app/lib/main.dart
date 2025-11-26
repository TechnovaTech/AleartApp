import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/home_screen.dart';
import 'services/localization_service.dart';
import 'services/api_service.dart';
import 'widgets/language_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalizationService.loadLanguage();
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
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: LanguageWrapper(child: const AuthWrapper()),
      debugShowCheckedModeBanner: false,
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
      // If new user, show "Get Started" page first
      return HomeScreen();
    }
  }
}