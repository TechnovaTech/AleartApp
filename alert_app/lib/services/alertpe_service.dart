import 'upi_app_detector.dart';
import 'notification_listener_service.dart';
import 'voice_alert_service.dart';
import 'background_service.dart';
import 'device_info_service.dart';
import 'push_notification_service.dart';
import 'api_service.dart';

class AlertPeService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize all services
      await VoiceAlertService.initialize();
      await PushNotificationService.initialize();
      await DeviceInfoService.updateLoginTimestamp();

      // Detect UPI apps
      final preferredApp = await UpiAppDetector.getPreferredUpiApp();
      print('Preferred UPI app: $preferredApp');

      // Start background services
      await BackgroundService.startBackgroundService();

      // Start notification listening
      await NotificationListenerService.startListening();

      _isInitialized = true;
      print('AlertPe services initialized successfully');
    } catch (e) {
      print('Error initializing AlertPe services: $e');
    }
  }

  static Future<void> handlePaymentReceived(Map<String, dynamic> paymentData) async {
    try {
      // Announce payment
      await VoiceAlertService.announcePayment(paymentData);

      // Save to database
      final userData = await ApiService.getCachedUserData();
      if (userData != null) {
        paymentData['userId'] = userData['_id'];
        await ApiService.post('/payments', paymentData);

        // Add timeline event
        await ApiService.post('/timeline/add', {
          'userId': userData['_id'],
          'eventType': 'payment_received',
          'title': 'Payment Received',
          'description': 'Received ₹${paymentData['amount']} via ${paymentData['paymentApp']}',
          'metadata': paymentData,
        });
      }

      print('Payment processed: ₹${paymentData['amount']}');
    } catch (e) {
      print('Error handling payment: $e');
    }
  }

  static Future<Map<String, dynamic>> getSystemStatus() async {
    return {
      'upiAppsDetected': await UpiAppDetector.getInstalledUpiApps(),
      'preferredUpiApp': await UpiAppDetector.getPreferredUpiApp(),
      'notificationPermission': await NotificationListenerService.isNotificationPermissionGranted(),
      'backgroundServiceRunning': await BackgroundService.isServiceRunning(),
      'voiceAlertsEnabled': await VoiceAlertService.isVoiceAlertsEnabled(),
      'deviceInfo': await DeviceInfoService.getDeviceInfo(),
      'fcmToken': await PushNotificationService.getFCMToken(),
    };
  }

  static Future<void> testAllFeatures() async {
    print('Testing AlertPe features...');

    // Test UPI app detection
    final apps = await UpiAppDetector.getInstalledUpiApps();
    print('Detected UPI apps: $apps');

    // Test voice alerts
    await VoiceAlertService.testVoiceAlert();

    // Test device info
    final deviceInfo = await DeviceInfoService.getDeviceInfo();
    print('Device info: $deviceInfo');

    print('Feature test completed');
  }

  static void dispose() {
    NotificationListenerService.stopListening();
    BackgroundService.stopBackgroundService();
    VoiceAlertService.dispose();
    _isInitialized = false;
  }
}