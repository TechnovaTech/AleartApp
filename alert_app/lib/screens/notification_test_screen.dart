import 'package:flutter/material.dart';
import 'dart:async';
import '../services/notification_service.dart';
import '../services/api_service.dart';

class NotificationTestScreen extends StatefulWidget {
  @override
  _NotificationTestScreenState createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  StreamSubscription? _notificationSubscription;
  List<Map<String, dynamic>> _notifications = [];
  bool _isListening = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final hasAccess = await NotificationService.checkPermissions();
    setState(() {
      _hasPermission = hasAccess;
    });
  }

  Future<void> _requestPermissions() async {
    await NotificationService.requestPermissions();
    await NotificationService.openNotificationSettings();
    
    // Recheck after user returns from settings
    Future.delayed(Duration(seconds: 2), () {
      _checkPermissions();
    });
  }

  void _startListening() {
    if (_isListening) return;
    
    _notificationSubscription = NotificationService.notificationStream.listen(
      (notification) {
        print('Received notification: $notification');
        
        // Parse UPI payment data
        final paymentData = NotificationService.parseUpiPayment(notification);
        
        setState(() {
          _notifications.insert(0, {
            ...notification,
            'parsedData': paymentData,
            'timestamp': DateTime.now().toString(),
          });
        });
        
        // Auto-save to database
        _savePaymentToDatabase(paymentData);
      },
      onError: (error) {
        print('Notification stream error: $error');
      },
    );
    
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() {
    _notificationSubscription?.cancel();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _savePaymentToDatabase(Map<String, String> paymentData) async {
    try {
      final response = await ApiService.savePayment(
        amount: double.parse(paymentData['amount'] ?? '0'),
        paymentApp: paymentData['paymentApp'] ?? 'Unknown',
        payerName: paymentData['payerName'] ?? 'Unknown User',
        upiId: paymentData['upiId'] ?? 'unknown@upi',
        transactionId: paymentData['transactionId'] ?? '',
        notificationText: paymentData['notificationText'] ?? '',
      );
      
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment saved automatically')),
        );
      }
    } catch (e) {
      print('Error saving payment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UPI Notification Test'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Permission Status
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: _hasPermission ? Colors.green[100] : Colors.red[100],
            child: Column(
              children: [
                Icon(
                  _hasPermission ? Icons.check_circle : Icons.error,
                  color: _hasPermission ? Colors.green : Colors.red,
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  _hasPermission 
                    ? 'Notification Access Granted' 
                    : 'Notification Access Required',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _hasPermission ? Colors.green[800] : Colors.red[800],
                  ),
                ),
                if (!_hasPermission) ...[
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _requestPermissions,
                    child: Text('Grant Permission'),
                  ),
                ],
              ],
            ),
          ),
          
          // Control Buttons
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _hasPermission && !_isListening ? _startListening : null,
                    child: Text('Start Listening'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isListening ? _stopListening : null,
                    child: Text('Stop Listening'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          
          // Status
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _isListening ? 'Listening for UPI notifications...' : 'Not listening',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: _isListening ? Colors.green : Colors.grey,
              ),
            ),
          ),
          
          // Notifications List
          Expanded(
            child: _notifications.isEmpty
              ? Center(
                  child: Text(
                    'No notifications received yet.\nMake a UPI payment to test.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final parsedData = notification['parsedData'] as Map<String, String>?;
                    
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ExpansionTile(
                        title: Text(
                          '${parsedData?['paymentApp'] ?? 'Unknown'} - ₹${parsedData?['amount'] ?? '0'}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(parsedData?['payerName'] ?? 'Unknown User'),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Package: ${notification['packageName']}'),
                                Text('Title: ${notification['title']}'),
                                Text('UPI ID: ${parsedData?['upiId']}'),
                                Text('Transaction ID: ${parsedData?['transactionId']}'),
                                SizedBox(height: 8),
                                Text('Full Text:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('${notification['text']}'),
                                SizedBox(height: 8),
                                Text('Time: ${notification['timestamp']}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}