import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class PermissionScreen extends StatefulWidget {
  @override
  _PermissionScreenState createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final hasPermissions = await NotificationService.checkPermissions();
    setState(() {
      _hasPermissions = hasPermissions;
    });
  }

  Future<void> _requestPermissions() async {
    await NotificationService.requestPermissions();
    await Future.delayed(Duration(seconds: 1));
    await _checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Permissions'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _hasPermissions ? Icons.check_circle : Icons.warning,
              size: 80,
              color: _hasPermissions ? Colors.green : Colors.orange,
            ),
            SizedBox(height: 20),
            Text(
              _hasPermissions ? 'Permissions Granted' : 'Permissions Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _hasPermissions ? Colors.green : Colors.orange,
              ),
            ),
            SizedBox(height: 20),
            Text(
              _hasPermissions 
                ? 'All required permissions have been granted. The app can now function properly.'
                : 'This app needs notification permissions to work properly. Please grant the required permissions.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 40),
            if (!_hasPermissions)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _requestPermissions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Grant Permissions',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            if (_hasPermissions)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Continue to App',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            SizedBox(height: 20),
            TextButton(
              onPressed: _checkPermissions,
              child: Text('Check Permissions Again'),
            ),
          ],
        ),
      ),
    );
  }
}