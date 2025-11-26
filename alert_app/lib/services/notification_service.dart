import 'dart:async';
import 'package:flutter/services.dart';

class NotificationService {
  static const MethodChannel _channel = MethodChannel('payment_notifications');
  static const EventChannel _eventChannel = EventChannel('payment_events');
  
  static StreamSubscription? _subscription;
  static final StreamController<Map<String, dynamic>> _paymentController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  static Stream<Map<String, dynamic>> get paymentStream => _paymentController.stream;
  
  static Future<void> initialize() async {
    try {
      // Request all permissions automatically
      await _channel.invokeMethod('requestPermissions');
      
      // Listen to payment notifications
      _subscription = _eventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is Map<String, dynamic>) {
            _paymentController.add(event);
          }
        },
        onError: (error) {
          print('Payment notification error: $error');
        },
      );
    } catch (e) {
      print('Failed to initialize notification service: $e');
    }
  }
  
  static Future<void> openNotificationSettings() async {
    try {
      await _channel.invokeMethod('openNotificationSettings');
    } catch (e) {
      print('Failed to open notification settings: $e');
    }
  }
  
  static void dispose() {
    _subscription?.cancel();
    _paymentController.close();
  }
}