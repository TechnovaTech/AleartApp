import 'package:flutter/material.dart';
import 'screens/get_started_screen.dart';

void main() {
  runApp(TestGetStartedApp());
}

class TestGetStartedApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Get Started',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GetStartedScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}