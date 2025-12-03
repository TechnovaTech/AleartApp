import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';

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
  ];

  static Future<List<Map<String, String>>> getInstalledUpiApps() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      
      // For Android API level 30+, we need special permission to query packages
      if (androidInfo.version.sdkInt >= 30) {
        return await _getInstalledAppsWithPermission();
      } else {
        return await _getInstalledAppsLegacy();
      }
    } catch (e) {
      // Fallback: return all apps (user will manually select)
      return _upiApps;
    }
  }

  static Future<List<Map<String, String>>> _getInstalledAppsWithPermission() async {
    try {
      final List<dynamic> installedPackages = await _channel.invokeMethod('getInstalledUpiApps');
      
      return _upiApps.where((app) {
        return installedPackages.contains(app['packageName']);
      }).toList();
    } catch (e) {
      return _upiApps; // Fallback
    }
  }

  static Future<List<Map<String, String>>> _getInstalledAppsLegacy() async {
    try {
      final List<dynamic> installedPackages = await _channel.invokeMethod('getInstalledPackages');
      
      return _upiApps.where((app) {
        return installedPackages.contains(app['packageName']);
      }).toList();
    } catch (e) {
      return _upiApps; // Fallback
    }
  }

  static List<Map<String, String>> getPriorityOrderedApps(List<Map<String, String>> installedApps) {
    // Priority order: PhonePe > Google Pay > Paytm > Others
    final List<String> priorityOrder = [
      'com.phonepe.app',
      'com.google.android.apps.nfc.payment',
      'net.one97.paytm',
    ];

    final List<Map<String, String>> orderedApps = [];
    
    // Add apps in priority order
    for (String packageName in priorityOrder) {
      final app = installedApps.firstWhere(
        (app) => app['packageName'] == packageName,
        orElse: () => {},
      );
      if (app.isNotEmpty) {
        orderedApps.add(app);
      }
    }
    
    // Add remaining apps
    for (Map<String, String> app in installedApps) {
      if (!priorityOrder.contains(app['packageName'])) {
        orderedApps.add(app);
      }
    }
    
    return orderedApps;
  }

  static String getRecommendedApp(List<Map<String, String>> installedApps) {
    final orderedApps = getPriorityOrderedApps(installedApps);
    return orderedApps.isNotEmpty ? orderedApps.first['name']! : 'Manual Entry';
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