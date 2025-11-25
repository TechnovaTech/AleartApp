import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  void initState() {
    super.initState();
    LocalizationService.loadLanguage().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.home), label: LocalizationService.translate('home')),
        BottomNavigationBarItem(icon: const Icon(Icons.qr_code_2), label: LocalizationService.translate('my_qr_code')),
        BottomNavigationBarItem(icon: const Icon(Icons.settings), label: LocalizationService.translate('settings')),
      ],
      currentIndex: widget.currentIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: widget.onTap,
    );
  }
}
