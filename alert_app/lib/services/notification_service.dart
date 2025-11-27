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
    
    // Extract UPI ID with better patterns
    String upiId = '';
    
    // Try multiple UPI ID patterns
    List<RegExp> upiPatterns = [
      RegExp(r'from\s+([a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+)', caseSensitive: false),
      RegExp(r'([a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+)', caseSensitive: false),
      RegExp(r'UPI\s+ID[:\s]+([a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+)', caseSensitive: false),
      RegExp(r'VPA[:\s]+([a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+)', caseSensitive: false),
    ];
    
    for (RegExp pattern in upiPatterns) {
      Match? match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null && match.group(1)!.contains('@')) {
        upiId = match.group(1)!;
        break;
      }
    }
    
    // If no UPI ID found, use generic UPI ID but still detect payment app
    if (upiId.isEmpty || !upiId.contains('@')) {
      upiId = 'payment@upi';
    }
    

    
    // Get payment app name - prioritize SMS text, then package, then sender
    String paymentApp = _extractPaymentAppFromText(text);
    if (paymentApp == 'UPI Payment') {
      if (packageName.isNotEmpty) {
        paymentApp = _getAppName(packageName);
      }
      if (paymentApp == 'UPI Payment' && sender.isNotEmpty) {
        paymentApp = _getAppNameFromSender(sender);
      }
    }
    
    // Debug print to see what's being detected
    print('SMS Text: $text');
    print('Package: $packageName');
    print('Sender: $sender');
    print('Detected App: $paymentApp');
    
    // Generate unique transaction ID using UPI ID, amount, and timestamp
    String transactionId = 'UPI_${upiId.replaceAll('@', '_')}_${amount}_${DateTime.now().millisecondsSinceEpoch}';
    
    return {
      'amount': amount,
      'upiId': upiId,
      'paymentApp': paymentApp,
      'transactionId': transactionId,
      'notificationText': text,
    };
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