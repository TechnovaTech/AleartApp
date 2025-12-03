import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'payment_parser_service.dart';
import 'voice_alert_service.dart';
import 'api_service.dart';

class NotificationListenerService {
  static const MethodChannel _channel = MethodChannel('notification_listener');
  static StreamSubscription? _subscription;
  
  static const List<String> upiPackages = [
    'com.phonepe.app',
    'com.google.android.apps.nfc.payment',
    'net.one97.paytm',
    'in.org.npci.upiapp',
    'in.amazon.mShop.android.shopping',
  ];

  static Future<bool> requestNotificationPermission() async {
    try {
      final result = await _channel.invokeMethod('requestPermission');
      return result ?? false;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  static Future<bool> isNotificationPermissionGranted() async {
    try {
      final result = await _channel.invokeMethod('isPermissionGranted');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> startListening() async {
    if (!await isNotificationPermissionGranted()) {
      await requestNotificationPermission();
      return;
    }

    try {
      _subscription = _channel.invokeMapMethod('startListening').asStream().listen(
        (data) => _handleNotification(data),
        onError: (error) => print('Notification listener error: $error'),
      );
    } catch (e) {
      print('Error starting notification listener: $e');
    }
  }

  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  static void _handleNotification(Map<dynamic, dynamic>? data) {
    if (data == null) return;

    final packageName = data['packageName'] as String?;
    final title = data['title'] as String?;
    final text = data['text'] as String?;
    final timestamp = data['timestamp'] as int?;

    // Only process UPI app notifications
    if (packageName == null || !upiPackages.contains(packageName)) return;
    if (text == null || text.isEmpty) return;

    print('UPI Notification received from $packageName: $text');

    // Parse payment data
    final paymentData = PaymentParserService.parseNotification(text, packageName);
    if (paymentData != null) {
      _processPayment(paymentData);
    }
  }

  static void _processPayment(Map<String, dynamic> paymentData) async {
    try {
      // Announce payment via TTS
      VoiceAlertService.announcePayment(paymentData);

      // Save to database
      await ApiService.post('/payments', paymentData);

      // Add to timeline
      await ApiService.post('/timeline/add', {
        'userId': paymentData['userId'],
        'eventType': 'payment_received',
        'title': 'Payment Received',
        'description': 'Received ₹${paymentData['amount']} via ${paymentData['paymentApp']}',
        'metadata': paymentData,
      });

      print('Payment processed successfully: ₹${paymentData['amount']}');
    } catch (e) {
      print('Error processing payment: $e');
    }
  }
}