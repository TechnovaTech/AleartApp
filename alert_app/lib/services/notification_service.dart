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
    
    // Only process UPI payment SMS - check for UPI keywords
    if (!_isUpiPaymentSMS(text, sender)) {
      return {
        'amount': '0',
        'payerName': '',
        'upiId': '',
        'paymentApp': '',
        'transactionId': '',
        'notificationText': text,
      };
    }
    
    // Extract amount using multiple regex patterns
    String amount = '0';
    
    // Try different amount patterns
    List<RegExp> amountPatterns = [
      RegExp(r'₹\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'Rs\.?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'INR\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'received\s*₹?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'credited\s*₹?\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false),
    ];
    
    for (RegExp pattern in amountPatterns) {
      Match? match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        amount = match.group(1)!.replaceAll(',', '');
        break;
      }
    }
    
    // Extract UPI ID
    RegExp upiRegex = RegExp(r'(\w+@\w+)', caseSensitive: false);
    Match? upiMatch = upiRegex.firstMatch(text);
    String upiId = upiMatch?.group(1) ?? 'unknown@upi';
    

    
    // Get payment app name from SMS text first, then package/sender
    String paymentApp = _extractPaymentAppFromText(text);
    if (paymentApp == 'UPI Payment') {
      paymentApp = packageName.isNotEmpty ? _getAppName(packageName) : _getAppNameFromSender(sender);
    }
    
    return {
      'amount': amount,
      'upiId': upiId,
      'paymentApp': paymentApp,
      'transactionId': 'TXN${DateTime.now().millisecondsSinceEpoch}',
      'notificationText': text,
    };
  }
  
  // Check if SMS is a UPI payment (not bank SMS)
  static bool _isUpiPaymentSMS(String text, String sender) {
    String textUpper = text.toUpperCase();
    String senderUpper = sender.toUpperCase();
    
    // Must contain UPI payment keywords
    bool hasUpiKeywords = textUpper.contains('UPI') || 
                         textUpper.contains('@') || 
                         textUpper.contains('GPAY') ||
                         textUpper.contains('PHONEPE') ||
                         textUpper.contains('PAYTM') ||
                         textUpper.contains('BHIM') ||
                         textUpper.contains('AMAZON PAY');
    
    // Must contain payment keywords
    bool hasPaymentKeywords = textUpper.contains('RECEIVED') ||
                             textUpper.contains('CREDITED') ||
                             textUpper.contains('PAID') ||
                             textUpper.contains('PAYMENT');
    
    // Exclude bank SMS (account balance, debit, etc.)
    bool isBankSMS = textUpper.contains('ACCOUNT BALANCE') ||
                     textUpper.contains('DEBITED') ||
                     textUpper.contains('WITHDRAWN') ||
                     textUpper.contains('ATM') ||
                     textUpper.contains('CARD USED');
    
    return hasUpiKeywords && hasPaymentKeywords && !isBankSMS;
  }
  
  // Extract payment app name from SMS text
  static String _extractPaymentAppFromText(String text) {
    String textUpper = text.toUpperCase();
    
    // 1. Google Pay detection
    if (textUpper.contains('GOOGLE PAY') || 
        textUpper.contains('GOOGLEPAY') ||
        textUpper.contains('G PAY') ||
        textUpper.contains('GPAY') ||
        textUpper.contains('VIA GOOGLE')) {
      return 'Google Pay';
    }
    // 2. PhonePe detection
    else if (textUpper.contains('PHONEPE') || 
             textUpper.contains('PHONE PE') ||
             textUpper.contains('VIA PHONEPE')) {
      return 'PhonePe';
    }
    // 3. Paytm detection
    else if (textUpper.contains('PAYTM') || 
             textUpper.contains('VIA PAYTM')) {
      return 'Paytm';
    }
    // 4. BHIM UPI detection
    else if (textUpper.contains('BHIM') || 
             textUpper.contains('VIA BHIM')) {
      return 'BHIM UPI';
    }
    // 5. Amazon Pay detection
    else if (textUpper.contains('AMAZON PAY') || 
             textUpper.contains('AMAZONPAY') ||
             textUpper.contains('VIA AMAZON')) {
      return 'Amazon Pay';
    }
    // 6. MobiKwik detection
    else if (textUpper.contains('MOBIKWIK') ||
             textUpper.contains('MOBI KWIK') ||
             textUpper.contains('VIA MOBIKWIK')) {
      return 'Mobikwik';
    }
    // 7. FreeCharge detection
    else if (textUpper.contains('FREECHARGE') ||
             textUpper.contains('FREE CHARGE') ||
             textUpper.contains('VIA FREECHARGE')) {
      return 'Freecharge';
    }
    // 8. CRED detection
    else if (textUpper.contains('CRED') ||
             textUpper.contains('VIA CRED')) {
      return 'CRED';
    }
    else {
      return 'UPI Payment';
    }
  }
  
  static String _getAppName(String packageName) {
    switch (packageName) {
      // Google Pay
      case 'com.google.android.apps.nbu.paisa.user':
      case 'com.google.android.apps.nbu.paisa':
      case 'com.google.android.gms':
        return 'Google Pay';
      // PhonePe
      case 'com.phonepe.app':
        return 'PhonePe';
      // Paytm
      case 'net.one97.paytm':
      case 'com.paytm':
        return 'Paytm';
      // BHIM UPI
      case 'in.org.npci.upiapp':
        return 'BHIM UPI';
      // Amazon Pay
      case 'com.amazon.mShop.android.shopping':
      case 'in.amazon.mShop.android.shopping':
        return 'Amazon Pay';
      // MobiKwik
      case 'com.mobikwik_new':
      case 'com.mobikwik.wallet':
        return 'Mobikwik';
      // FreeCharge
      case 'com.freecharge.android':
        return 'Freecharge';
      // CRED
      case 'com.dreamplug.androidapp':
        return 'CRED';
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
    } else if (senderUpper.contains('MOBIKWIK')) {
      return 'Mobikwik';
    } else if (senderUpper.contains('FREECHARGE')) {
      return 'Freecharge';
    } else if (senderUpper.contains('CRED')) {
      return 'CRED';
    } else if (senderUpper.contains('UPI')) {
      return 'UPI Payment';
    } else {
      return 'Bank UPI';
    }
  }
}