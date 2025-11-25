import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'services/localization_service.dart';
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
      home: LanguageWrapper(child: const HomeScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}