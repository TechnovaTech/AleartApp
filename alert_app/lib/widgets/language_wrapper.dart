import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class LanguageWrapper extends StatefulWidget {
  final Widget child;
  
  const LanguageWrapper({super.key, required this.child});
  
  @override
  State<LanguageWrapper> createState() => _LanguageWrapperState();
}

class _LanguageWrapperState extends State<LanguageWrapper> {
  String _currentLanguage = '';
  
  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }
  
  void _loadLanguage() async {
    await LocalizationService.loadLanguage();
    setState(() {
      _currentLanguage = LocalizationService.currentLanguage;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}