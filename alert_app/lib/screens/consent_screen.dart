import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({Key? key}) : super(key: key);

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool isLoading = false;

  Future<void> _acceptAndRequestPermissions() async {
    // Add timeline event for consent granted
    try {
      final userData = await ApiService.getCachedUserData();
      if (userData != null) {
        await ApiService.post('/timeline/add', {
          'userId': userData['_id'],
          'eventType': 'notification-consent-granted',
          'title': 'Notification Consent Granted',
          'description': 'User granted permission to read notifications',
        });
      }
    } catch (e) {
      // Continue even if timeline fails
    }
    
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Request SMS permission
      final smsStatus = await Permission.sms.request();
      
      // Request notification access (for notification listener)
      final notificationStatus = await Permission.notification.request();
      
      if (smsStatus.isGranted && notificationStatus.isGranted) {
        // Permissions granted, navigate to main app
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Show error dialog
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error requesting permissions: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'AlertPe needs SMS and notification permissions to monitor your UPI payments. Please grant these permissions in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.security,
                  size: 60,
                  color: Colors.blue,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Privacy & Permissions',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Description
              const Text(
                'AlertPe needs access to your SMS and notifications to automatically detect UPI payments and provide you with real-time alerts.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Permission items
              _buildPermissionItem(
                Icons.sms,
                'SMS Access',
                'Read SMS messages to detect UPI payment notifications',
              ),
              
              const SizedBox(height: 16),
              
              _buildPermissionItem(
                Icons.notifications,
                'Notification Access',
                'Monitor app notifications for payment alerts',
              ),
              
              const SizedBox(height: 32),
              
              // Legal disclaimer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lock,
                          color: Colors.green,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Privacy & Data Protection',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'We read UPI transaction notifications ONLY on your device. No notification content is uploaded or stored on servers. By continuing, you agree to the app permissions.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Accept/Decline buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Decline',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _acceptAndRequestPermissions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Accept & Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Skip button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                child: const Text(
                  'Skip for now',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}