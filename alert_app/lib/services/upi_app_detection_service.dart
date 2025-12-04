import 'package:flutter/services.dart';

class UpiAppDetectionService {
  static const MethodChannel _channel = MethodChannel('upi_app_detection');
  
  static Future<List<Map<String, String>>> getInstalledUpiApps() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getInstalledUpiApps') ?? [];
      
      return result.map((app) => Map<String, String>.from(app)).toList();
    } catch (e) {
      print('Error detecting UPI apps: $e');
      // Return default UPI apps as fallback
      return _getDefaultUpiApps();
    }
  }
  
  static List<Map<String, String>> _getDefaultUpiApps() {
    return [
      {
        'name': 'PhonePe',
        'packageName': 'com.phonepe.app',
      },
      {
        'name': 'Google Pay',
        'packageName': 'com.google.android.apps.nfc.payment',
      },
      {
        'name': 'Paytm',
        'packageName': 'net.one97.paytm',
      },
      {
        'name': 'BHIM',
        'packageName': 'in.org.npci.upiapp',
      },
      {
        'name': 'Amazon Pay',
        'packageName': 'in.amazon.mShop.android.shopping',
      },
    ];
  }
  
  static bool isValidUpiId(String upiId) {
    final RegExp upiRegex = RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');
    return upiRegex.hasMatch(upiId);
  }
  
  static Future<bool> isAppInstalled(String packageName) async {
    try {
      final bool result = await _channel.invokeMethod('isAppInstalled', {
        'packageName': packageName,
      });
      return result;
    } catch (e) {
      print('Error checking app installation: $e');
      return false;
    }
  }
}