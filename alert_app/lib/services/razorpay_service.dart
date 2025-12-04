import 'package:flutter/services.dart';
import 'api_service.dart';

class RazorpayService {
  static const MethodChannel _channel = MethodChannel('razorpay_flutter');
  
  static Future<Map<String, dynamic>> createSubscription({
    required String userId,
    required String planId,
    double? amount,
  }) async {
    try {
      final response = await ApiService.post('/razorpay/create-subscription', {
        'userId': userId,
        'planId': planId,
        'amount': amount ?? 99,
      });
      
      if (response['success']) {
        return {
          'success': true,
          'subscriptionId': response['subscriptionId'],
          'shortUrl': response['shortUrl'] ?? 'upi://pay?pa=merchant@razorpay&pn=AlertPe&tr=${DateTime.now().millisecondsSinceEpoch}&tn=Subscription&am=${amount ?? 99}&cu=INR',
        };
      }
      
      return response;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  static Future<void> openCheckout({
    required String subscriptionId,
    required String shortUrl,
    required Function(Map<String, dynamic>) onSuccess,
    required Function(Map<String, dynamic>) onError,
    String? specificApp,
    double? amount,
  }) async {
    try {
      // Try to launch UPI app first if it's a UPI link
      bool success = false;
      
      if (shortUrl.startsWith('upi://')) {
        // Try specific UPI app first
        if (specificApp != null) {
          success = await _launchUpiIntent(shortUrl, specificApp);
        }
        
        // If specific app failed or not specified, try generic UPI
        if (!success) {
          success = await _launchUpiIntent(shortUrl, null);
        }
      }
      
      // If UPI failed, try browser
      if (!success) {
        success = await _launchPaymentUrl(shortUrl);
      }
      
      if (success) {
        onSuccess({'status': 'success', 'paymentUrl': shortUrl});
      } else {
        onError({'error': 'Failed to open payment'});
      }
    } catch (e) {
      onError({'error': e.toString()});
    }
  }
  
  static Future<bool> _launchPaymentUrl(String paymentUrl) async {
    try {
      final result = await _channel.invokeMethod('launchPaymentUrl', {
        'url': paymentUrl,
      });
      return result ?? false;
    } catch (e) {
      print('Failed to launch payment URL: $e');
      return false;
    }
  }
  
  static Future<bool> _launchUpiIntent(String upiUrl, String? specificApp) async {
    try {
      final result = await _channel.invokeMethod('launchUpiIntent', {
        'url': upiUrl,
        'specificApp': specificApp,
      });
      return result ?? false;
    } catch (e) {
      print('Failed to launch UPI intent: $e');
      return false;
    }
  }
  
  static Future<Map<String, dynamic>> cancelSubscription(String userId) async {
    try {
      final response = await ApiService.post('/razorpay/cancel-subscription', {
        'userId': userId,
      });
      
      return response;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  static Future<Map<String, dynamic>> getSubscriptionStatus(String userId) async {
    try {
      final response = await ApiService.get('/subscription/status?userId=$userId');
      return response;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  static Future<Map<String, dynamic>> createMandate({
    required String userId,
    required String planId,
    required double amount,
    double? verificationAmount,
    String? upiApp,
  }) async {
    try {
      final response = await ApiService.post('/razorpay/create-mandate', {
        'userId': userId,
        'planId': planId,
        'amount': amount,
        'verificationAmount': verificationAmount,
        'upiApp': upiApp,
      });
      
      return response;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  static Future<void> openMandateApproval({
    required String mandateUrl,
    required String mandateId,
    String? upiApp,
    required Function(Map<String, dynamic>) onSuccess,
    required Function(Map<String, dynamic>) onError,
  }) async {
    try {
      bool success = false;
      
      // Try to open in specific UPI app first
      if (upiApp != null && mandateUrl.startsWith('upi://')) {
        success = await _launchUpiIntent(mandateUrl, upiApp);
      }
      
      // If UPI app failed, try generic UPI
      if (!success && mandateUrl.startsWith('upi://')) {
        success = await _launchUpiIntent(mandateUrl, null);
      }
      
      // If UPI failed, open in browser
      if (!success) {
        success = await _launchPaymentUrl(mandateUrl);
      }
      
      if (success) {
        onSuccess({'status': 'success', 'mandateId': mandateId});
      } else {
        onError({'error': 'Failed to open mandate approval'});
      }
    } catch (e) {
      onError({'error': e.toString()});
    }
  }
}