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
      // Launch Razorpay payment link
      final success = await _launchPaymentUrl(shortUrl);
      if (success) {
        onSuccess({'status': 'success', 'paymentUrl': shortUrl});
      } else {
        onError({'error': 'Failed to open payment page'});
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
}