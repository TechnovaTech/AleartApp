import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

class DeviceCompatibilityService {
  static const MethodChannel _channel = MethodChannel('device_compatibility');
  
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    
    return {
      'manufacturer': androidInfo.manufacturer.toLowerCase(),
      'model': androidInfo.model,
      'brand': androidInfo.brand.toLowerCase(),
      'sdkInt': androidInfo.version.sdkInt,
      'release': androidInfo.version.release,
    };
  }
  
  static Future<bool> isUpiIntentSupported() async {
    try {
      final result = await _channel.invokeMethod('checkUpiSupport');
      return result ?? true;
    } catch (e) {
      return true; // Assume supported if check fails
    }
  }
  
  static Future<List<String>> getProblematicDevices() async {
    return [
      'samsung sm-a505f', // Galaxy A50 - UPI intent issues
      'xiaomi redmi note 7', // MIUI restrictions
      'oppo cph1909', // ColorOS restrictions
      'vivo v15 pro', // FunTouch OS issues
      'realme rmx1901', // Realme UI restrictions
    ];
  }
  
  static Future<bool> isProblematicDevice() async {
    final deviceInfo = await getDeviceInfo();
    final deviceModel = '${deviceInfo['brand']} ${deviceInfo['model']}'.toLowerCase();
    final problematicDevices = await getProblematicDevices();
    
    return problematicDevices.any((device) => deviceModel.contains(device));
  }
  
  static Future<Map<String, String>> getDeviceSpecificInstructions() async {
    final deviceInfo = await getDeviceInfo();
    final manufacturer = deviceInfo['manufacturer'];
    
    switch (manufacturer) {
      case 'xiaomi':
        return {
          'title': 'MIUI Setup Required',
          'instruction': 'Go to Settings > Apps > Manage Apps > AlertPe > Other Permissions > Enable "Display pop-up windows while running in background"',
        };
      case 'oppo':
        return {
          'title': 'ColorOS Setup Required', 
          'instruction': 'Go to Settings > Battery > App Battery Management > AlertPe > Allow background activity',
        };
      case 'vivo':
        return {
          'title': 'FunTouch OS Setup Required',
          'instruction': 'Go to Settings > Battery > Background App Refresh > AlertPe > Enable',
        };
      case 'samsung':
        return {
          'title': 'Samsung Setup Required',
          'instruction': 'Go to Settings > Device Care > Battery > App Power Management > Apps that won\'t be put to sleep > Add AlertPe',
        };
      default:
        return {
          'title': 'Standard Setup',
          'instruction': 'Ensure AlertPe has all required permissions and is not being optimized by battery saver',
        };
    }
  }
}