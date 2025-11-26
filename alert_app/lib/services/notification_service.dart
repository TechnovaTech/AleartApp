import 'package:flutter/services.dart';
import 'dart:async';

class NotificationService {
  static const MethodChannel _channel = MethodChannel('payment_notifications');
  static const EventChannel _eventChannel = EventChannel('payment_events');
  
  static Stream<Map<String, dynamic>>? _notificationStream;
  
  // Get notification stream
  static Stream<Map<String, dynamic>> get notificationStream {
    _notificationStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event));
    return _notificationStream!;
  }
  
  // Request all required permissions
  static Future<bool> requestPermissions() async {
    try {
      final result = await _channel.invokeMethod('requestPermissions');
      return result ?? false;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }
  
  // Open notification listener settings
  static Future<void> openNotificationSettings() async {
    try {
      await _channel.invokeMethod('openNotificationSettings');
    } catch (e) {
      print('Error opening notification settings: $e');
    }
  }
  
  // Check if basic permissions are granted
  static Future<bool> checkPermissions() async {
    try {
      final result = await _channel.invokeMethod('checkPermissions');
      return result ?? false;
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }
  
  // Parse UPI payment from notification text
  static Map<String, String> parseUpiPayment(Map<String, dynamic> notification) {
    String text = notification['text'] ?? '';
    String packageName = notification['packageName'] ?? '';
    
    // Extract amount using regex
    RegExp amountRegex = RegExp(r'₹\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false);
    Match? amountMatch = amountRegex.firstMatch(text);
    String amount = amountMatch?.group(1)?.replaceAll(',', '') ?? '0';
    
    // Extract UPI ID
    RegExp upiRegex = RegExp(r'(\w+@\w+)', caseSensitive: false);
    Match? upiMatch = upiRegex.firstMatch(text);
    String upiId = upiMatch?.group(1) ?? 'unknown@upi';
    
    // Extract payer name (usually before "paid" or "sent")
    RegExp nameRegex = RegExp(r'(?:from\s+|by\s+)?([A-Za-z\s]+)(?:\s+paid|\s+sent)', caseSensitive: false);
    Match? nameMatch = nameRegex.firstMatch(text);
    String payerName = nameMatch?.group(1)?.trim() ?? 'Unknown User';
    
    // Get payment app name
    String paymentApp = _getAppName(packageName);
    
    return {
      'amount': amount,
      'payerName': payerName,
      'upiId': upiId,
      'paymentApp': paymentApp,
      'transactionId': 'TXN${DateTime.now().millisecondsSinceEpoch}',
      'notificationText': text,
    };
  }
  
  static String _getAppName(String packageName) {
    switch (packageName) {
      case 'com.google.android.apps.nbu.paisa.user':
        return 'Google Pay';
      case 'com.phonepe.app':
        return 'PhonePe';
      case 'net.one97.paytm':
        return 'Paytm';
      case 'in.org.npci.upiapp':
        return 'BHIM UPI';
      case 'com.amazon.mShop.android.shopping':
        return 'Amazon Pay';
      default:
        return 'UPI Payment';
    }
  }
}