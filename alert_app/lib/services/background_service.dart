import 'dart:async';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'notification_listener_service.dart';

class BackgroundService {
  static const MethodChannel _channel = MethodChannel('background_service');
  static bool _isRunning = false;

  static Future<bool> requestAutoStartPermission() async {
    try {
      final result = await _channel.invokeMethod('requestAutoStart');
      return result ?? false;
    } catch (e) {
      print('Error requesting auto-start permission: $e');
      return false;
    }
  }

  static Future<bool> requestBatteryOptimizationExemption() async {
    try {
      final result = await _channel.invokeMethod('requestBatteryOptimization');
      return result ?? false;
    } catch (e) {
      print('Error requesting battery optimization exemption: $e');
      return false;
    }
  }

  static Future<void> startBackgroundService() async {
    if (_isRunning) return;

    // Request necessary permissions
    await requestAutoStartPermission();
    await requestBatteryOptimizationExemption();

    try {
      await _channel.invokeMethod('startBackgroundService');
      _isRunning = true;
      
      // Start notification listener
      await NotificationListenerService.startListening();
      
      print('Background service started successfully');
    } catch (e) {
      print('Error starting background service: $e');
    }
  }

  static Future<void> stopBackgroundService() async {
    if (!_isRunning) return;

    try {
      await _channel.invokeMethod('stopBackgroundService');
      _isRunning = false;
      
      // Stop notification listener
      NotificationListenerService.stopListening();
      
      print('Background service stopped');
    } catch (e) {
      print('Error stopping background service: $e');
    }
  }

  static Future<bool> isServiceRunning() async {
    try {
      final result = await _channel.invokeMethod('isServiceRunning');
      _isRunning = result ?? false;
      return _isRunning;
    } catch (e) {
      return false;
    }
  }

  static Future<void> ensureServiceRunning() async {
    final isRunning = await isServiceRunning();
    if (!isRunning) {
      await startBackgroundService();
    }
  }

  // Background isolate for processing notifications
  static void backgroundIsolateEntryPoint(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      if (message is Map) {
        _processNotificationInBackground(message);
      }
    });
  }

  static void _processNotificationInBackground(Map<String, dynamic> data) {
    // Process notification in background isolate
    // This ensures the app continues working even when minimized
    print('Processing notification in background: ${data['text']}');
  }
}