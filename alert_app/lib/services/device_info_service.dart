import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceInfoService {
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    
    Map<String, dynamic> info = {
      'appVersion': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'packageName': packageInfo.packageName,
      'platform': Platform.operatingSystem,
      'loginTimestamp': DateTime.now().toIso8601String(),
    };

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      info.addAll({
        'deviceId': androidInfo.id,
        'deviceModel': androidInfo.model,
        'deviceBrand': androidInfo.brand,
        'androidVersion': androidInfo.version.release,
        'sdkVersion': androidInfo.version.sdkInt,
        'manufacturer': androidInfo.manufacturer,
        'isPhysicalDevice': androidInfo.isPhysicalDevice,
      });
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      info.addAll({
        'deviceId': iosInfo.identifierForVendor,
        'deviceModel': iosInfo.model,
        'deviceName': iosInfo.name,
        'iosVersion': iosInfo.systemVersion,
        'isPhysicalDevice': iosInfo.isPhysicalDevice,
      });
    }

    return info;
  }

  static Future<String> getUniqueDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('unique_device_id');
    
    if (deviceId == null) {
      final deviceInfo = await getDeviceInfo();
      deviceId = deviceInfo['deviceId'] ?? _generateUniqueId();
      await prefs.setString('unique_device_id', deviceId);
    }
    
    return deviceId;
  }

  static String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'DEV_${Platform.operatingSystem.toUpperCase()}_$timestamp$random';
  }

  static Future<void> updateLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_login_timestamp', DateTime.now().toIso8601String());
  }

  static Future<String?> getLastLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_login_timestamp');
  }

  static Future<Map<String, dynamic>> getAppUsageStats() async {
    final prefs = await SharedPreferences.getInstance();
    
    final installDate = prefs.getString('app_install_date') ?? DateTime.now().toIso8601String();
    final launchCount = prefs.getInt('app_launch_count') ?? 0;
    final totalUsageTime = prefs.getInt('total_usage_time_minutes') ?? 0;
    
    // Increment launch count
    await prefs.setInt('app_launch_count', launchCount + 1);
    
    // Set install date if not set
    if (!prefs.containsKey('app_install_date')) {
      await prefs.setString('app_install_date', DateTime.now().toIso8601String());
    }

    return {
      'installDate': installDate,
      'launchCount': launchCount + 1,
      'totalUsageTimeMinutes': totalUsageTime,
      'lastLaunchDate': DateTime.now().toIso8601String(),
    };
  }

  static Future<void> trackUsageTime(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUsage = prefs.getInt('total_usage_time_minutes') ?? 0;
    await prefs.setInt('total_usage_time_minutes', currentUsage + minutes);
  }
}