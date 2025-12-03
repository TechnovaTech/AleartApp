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
      // Use dynamic amount or default
      final paymentAmount = amount?.toStringAsFixed(2) ?? '99.00';
      final upiUrl = 'upi://pay?pa=merchant@razorpay&pn=AlertPe&tr=${DateTime.now().millisecondsSinceEpoch}&tn=Subscription Payment&am=$paymentAmount&cu=INR';
      
      final success = await _launchUpiIntent(upiUrl, specificApp);
      if (success) {
        onSuccess({'status': 'success', 'app': specificApp ?? 'generic'});
      } else {
        onError({'error': 'Failed to launch UPI app'});
      }
    } catch (e) {
      onError({'error': e.toString()});
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
}