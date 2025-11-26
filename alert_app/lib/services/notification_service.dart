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
  
  // Parse UPI payment from SMS/notification text
  static Map<String, String> parseUpiPayment(Map<String, dynamic> data) {
    String text = data['text'] ?? data['message'] ?? '';
    String sender = data['sender'] ?? '';
    String packageName = data['packageName'] ?? '';
    
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
    
    // Get payment app name from package or sender
    String paymentApp = packageName.isNotEmpty ? _getAppName(packageName) : _getAppNameFromSender(sender);
    
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
  
  static String _getAppNameFromSender(String sender) {
    String senderUpper = sender.toUpperCase();
    if (senderUpper.contains('GOOGLEPAY') || senderUpper.contains('GPAY')) {
      return 'Google Pay';
    } else if (senderUpper.contains('PHONEPE')) {
      return 'PhonePe';
    } else if (senderUpper.contains('PAYTM')) {
      return 'Paytm';
    } else if (senderUpper.contains('BHIM')) {
      return 'BHIM UPI';
    } else if (senderUpper.contains('AMAZON')) {
      return 'Amazon Pay';
    } else if (senderUpper.contains('UPI') || senderUpper.contains('BANK')) {
      return 'Bank UPI';
    } else {
      return 'UPI Payment';
    }
  }
}