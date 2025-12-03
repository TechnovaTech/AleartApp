import 'package:flutter/services.dart';
import 'api_service.dart';

class RazorpayService {
  static const MethodChannel _channel = MethodChannel('razorpay_flutter');
  
  static Future<Map<String, dynamic>> createSubscription({
    required String userId,
    required String planId,
  }) async {
    try {
      final response = await ApiService.post('/razorpay/create-subscription', {
        'userId': userId,
        'planId': planId,
      });
      
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
  }) async {
    try {
      // For UPI Autopay, we'll use the short URL approach
      await _launchUpiIntent(shortUrl);
    } catch (e) {
      onError({'error': e.toString()});
    }
  }
  
  static Future<void> _launchUpiIntent(String shortUrl) async {
    try {
      await _channel.invokeMethod('launchUpiIntent', {
        'url': shortUrl,
      });
    } catch (e) {
      throw Exception('Failed to launch UPI intent: $e');
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