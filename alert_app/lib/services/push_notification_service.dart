import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class PushNotificationService {
  static FirebaseMessaging? _firebaseMessaging;
  static FlutterLocalNotificationsPlugin? _localNotifications;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    _firebaseMessaging = FirebaseMessaging.instance;
    _localNotifications = FlutterLocalNotificationsPlugin();

    // Request permission
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token
    await _getFCMToken();

    // Setup message handlers
    _setupMessageHandlers();

    _isInitialized = true;
  }

  static Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotifications!.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  static Future<void> _getFCMToken() async {
    try {
      String? token = await _firebaseMessaging!.getToken();
      if (token != null) {
        print('FCM Token: $token');
        await _saveFCMToken(token);
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  static Future<void> _saveFCMToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);

      // Send token to server
      final userData = await ApiService.getCachedUserData();
      if (userData != null) {
        await ApiService.post('/user/fcm-token', {
          'userId': userData['_id'],
          'fcmToken': token,
          'platform': 'android',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  static void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification taps when app is terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.notification?.title}');
    
    // Show local notification
    await _showLocalNotification(
      title: message.notification?.title ?? 'AlertPe',
      body: message.notification?.body ?? '',
      data: message.data,
    );
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Received background message: ${message.notification?.title}');
  }

  static void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
    // Handle navigation based on notification data
  }

  static void _onNotificationTapped(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'alertpe_channel',
      'AlertPe Notifications',
      channelDescription: 'Notifications from AlertPe admin',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications!.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: data?.toString(),
    );
  }

  static Future<void> sendNotificationToUser(String userId, String title, String body) async {
    try {
      await ApiService.post('/admin/send-notification', {
        'userId': userId,
        'title': title,
        'body': body,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging!.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging!.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  static Future<String?> getFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }
}