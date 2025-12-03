import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:installed_apps/installed_apps.dart';

class UpiAppDetectionService {
  static const MethodChannel _channel = MethodChannel('upi_app_detection');
  
  static final List<Map<String, String>> _upiApps = [
    {
      'name': 'PhonePe',
      'packageName': 'com.phonepe.app',
      'icon': 'assets/images/payment_icons/icons8-phone-pe.png',
    },
    {
      'name': 'Google Pay',
      'packageName': 'com.google.android.apps.nfc.payment',
      'icon': 'assets/images/payment_icons/icons8-google-pay.png',
    },
    {
      'name': 'GPay',
      'packageName': 'com.google.android.apps.walletnfcrel',
      'icon': 'assets/images/payment_icons/icons8-google-pay.png',
    },
    {
      'name': 'Paytm',
      'packageName': 'net.one97.paytm',
      'icon': 'assets/images/payment_icons/icons8-paytm.png',
    },
    {
      'name': 'BHIM',
      'packageName': 'in.org.npci.upiapp',
      'icon': 'assets/images/payment_icons/icons8-bhim.png',
    },
    {
      'name': 'Amazon Pay',
      'packageName': 'in.amazon.mShop.android.shopping',
      'icon': 'assets/images/payment_icons/amazon-pay-svgrepo-com.png',
    },
    {
      'name': 'MobiKwik',
      'packageName': 'com.mobikwik_new',
      'icon': 'assets/images/payment_icons/mobikwik.png',
    },
    {
      'name': 'Freecharge',
      'packageName': 'com.freecharge.android',
      'icon': 'assets/images/payment_icons/freecharge.png',
    },
    {
      'name': 'JioMoney',
      'packageName': 'com.ril.jio.jiomoney',
      'icon': 'assets/images/payment_icons/jiomoney.png',
    },
  ];

  static Future<List<Map<String, String>>> getInstalledUpiApps() async {
    try {
      // Return top 4 most common UPI apps to avoid performance issues
      return _upiApps.take(4).toList();
    } catch (e) {
      return _upiApps.take(4).toList();
    }
  }

  static Future<List<Map<String, String>>> _getInstalledAppsWithPermission() async {
    try {
      final installedApps = await InstalledApps.getInstalledApps(true, true);
      final List<String> installedPackages = installedApps.map((app) => app.packageName as String).toList();
      
      return _upiApps.where((app) {
        return installedPackages.contains(app['packageName']);
      }).toList();
    } catch (e) {
      return _upiApps; // Fallback
    }
  }

  static Future<List<Map<String, String>>> _getInstalledAppsLegacy() async {
    try {
      final installedApps = await InstalledApps.getInstalledApps(false, false);
      final List<String> installedPackages = installedApps.map((app) => app.packageName as String).toList();
      
      return _upiApps.where((app) {
        return installedPackages.contains(app['packageName']);
      }).toList();
    } catch (e) {
      return _upiApps; // Fallback
    }
  }

  static List<Map<String, String>> getPriorityOrderedApps(List<Map<String, String>> installedApps) {
    // Strict priority order: PhonePe > Google Pay > Paytm > Others
    final List<String> priorityOrder = [
      'com.phonepe.app',
      'com.google.android.apps.nfc.payment',
      'com.google.android.apps.walletnfcrel',
      'net.one97.paytm',
      'in.org.npci.upiapp',
      'in.amazon.mShop.android.shopping',
      'com.mobikwik_new',
      'com.freecharge.android',
      'com.ril.jio.jiomoney',
    ];

    final List<Map<String, String>> orderedApps = [];
    
    // Add apps in strict priority order only
    for (String packageName in priorityOrder) {
      final app = installedApps.firstWhere(
        (app) => app['packageName'] == packageName,
        orElse: () => {},
      );
      if (app.isNotEmpty) {
        orderedApps.add(app);
      }
    }
    
    return orderedApps;
  }

  static String getRecommendedApp(List<Map<String, String>> installedApps) {
    final orderedApps = getPriorityOrderedApps(installedApps);
    return orderedApps.isNotEmpty ? orderedApps.first['name']! : 'Manual Entry';
  }

  static Map<String, String>? getTopPriorityApp(List<Map<String, String>> installedApps) {
    final orderedApps = getPriorityOrderedApps(installedApps);
    return orderedApps.isNotEmpty ? orderedApps.first : null;
  }

  static bool hasAnyUpiApp(List<Map<String, String>> installedApps) {
    return getPriorityOrderedApps(installedApps).isNotEmpty;
  }

  static bool isValidUpiId(String upiId) {
    // Basic UPI ID validation
    final RegExp upiRegex = RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');
    return upiRegex.hasMatch(upiId);
  }

  static String? extractUpiIdFromText(String text) {
    // Extract UPI ID from notification text
    final RegExp upiRegex = RegExp(r'([a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64})');
    final match = upiRegex.firstMatch(text);
    return match?.group(1);
  }
}