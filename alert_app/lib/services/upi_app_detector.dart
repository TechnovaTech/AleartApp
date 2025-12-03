import 'package:device_apps/device_apps.dart';

class UpiAppDetector {
  static const Map<String, String> upiApps = {
    'com.phonepe.app': 'PhonePe',
    'com.google.android.apps.nfc.payment': 'Google Pay',
    'net.one97.paytm': 'Paytm',
    'in.org.npci.upiapp': 'BHIM',
    'in.amazon.mShop.android.shopping': 'Amazon Pay',
  };

  static Future<List<Map<String, String>>> getInstalledUpiApps() async {
    List<Map<String, String>> installedApps = [];
    
    for (String packageName in upiApps.keys) {
      bool isInstalled = await DeviceApps.isAppInstalled(packageName);
      if (isInstalled) {
        installedApps.add({
          'packageName': packageName,
          'appName': upiApps[packageName]!,
        });
      }
    }
    
    return installedApps;
  }

  static Future<String> getPreferredUpiApp() async {
    // Priority order: PhonePe → GPay → Paytm → BHIM → Amazon Pay
    List<String> priorityOrder = [
      'com.phonepe.app',
      'com.google.android.apps.nfc.payment', 
      'net.one97.paytm',
      'in.org.npci.upiapp',
      'in.amazon.mShop.android.shopping',
    ];
    
    for (String packageName in priorityOrder) {
      bool isInstalled = await DeviceApps.isAppInstalled(packageName);
      if (isInstalled) {
        return upiApps[packageName]!;
      }
    }
    
    return 'Manual Entry'; // No UPI app found
  }
}