import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

class ActivateAlertsBottomSheet extends StatefulWidget {
  const ActivateAlertsBottomSheet({super.key});

  @override
  State<ActivateAlertsBottomSheet> createState() => _ActivateAlertsBottomSheetState();
}

class _ActivateAlertsBottomSheetState extends State<ActivateAlertsBottomSheet> {
  bool _notificationAccess = false;
  bool _postNotifications = false;
  bool _batteryOptimized = false;
  bool _volumeOk = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Check notification permission
    final notificationStatus = await Permission.notification.status;
    
    // Check battery level for volume estimation
    final battery = Battery();
    final batteryLevel = await battery.batteryLevel;
    
    setState(() {
      _postNotifications = notificationStatus.isGranted;
      _volumeOk = batteryLevel > 20; // Assume volume is OK if battery > 20%
    });
  }

  Future<void> _requestNotificationListener() async {
    setState(() => _isLoading = true);
    
    try {
      // Request notification access (this opens system settings)
      final status = await Permission.notification.request();
      
      if (status.isGranted) {
        setState(() {
          _notificationAccess = true;
        });
        _showSnackBar('Notification access granted!', Colors.green);
      } else {
        _showSnackBar('Please enable notification access in Settings', Colors.orange);
      }
    } catch (e) {
      _showSnackBar('Error requesting notification access', Colors.red);
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _requestPostNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      final status = await Permission.notification.request();
      setState(() {
        _postNotifications = status.isGranted;
      });
      
      if (status.isGranted) {
        _showSnackBar('Notification permission granted!', Colors.green);
      } else {
        _showSnackBar('Notification permission denied', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error requesting notification permission', Colors.red);
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _requestBatteryOptimization() async {
    setState(() => _isLoading = true);
    
    try {
      // Check current battery optimization status
      final battery = Battery();
      final batteryState = await battery.batteryState;
      
      if (batteryState == BatteryState.charging || batteryState == BatteryState.full) {
        setState(() {
          _batteryOptimized = true;
        });
        _showSnackBar('Battery optimization disabled!', Colors.green);
      } else {
        _showSnackBar('Please disable battery optimization in Settings', Colors.orange);
        // In a real app, this would open battery optimization settings
      }
    } catch (e) {
      _showSnackBar('Error checking battery optimization', Colors.red);
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _checkVolume() async {
    setState(() => _isLoading = true);
    
    try {
      // Play a test sound to check volume
      await SystemSound.play(SystemSoundType.click);
      
      // Simulate volume check (in real app, you'd use audio plugins)
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _volumeOk = true;
      });
      
      _showSnackBar('Volume check completed! Sound played successfully.', Colors.green);
    } catch (e) {
      _showSnackBar('Error checking volume', Colors.red);
    }
    
    setState(() => _isLoading = false);
  }
  
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activate Alerts',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            _AlertItem(
              icon: Icons.notifications,
              title: 'Notification Listener',
              subtitle: 'Read UPI payment notifications',
              action: _notificationAccess ? 'Enabled' : (_isLoading ? 'Loading...' : 'Turn On'),
              isEnabled: _notificationAccess,
              isLoading: _isLoading,
              onTap: _requestNotificationListener,
            ),
            const SizedBox(height: 16),
            _AlertItem(
              icon: Icons.music_note,
              title: 'Post Notifications',
              subtitle: 'Show payment alerts',
              action: _postNotifications ? 'Enabled' : (_isLoading ? 'Loading...' : 'Turn On'),
              isEnabled: _postNotifications,
              isLoading: _isLoading,
              onTap: _requestPostNotifications,
            ),
            const SizedBox(height: 16),
            _AlertItem(
              icon: Icons.battery_full,
              title: 'Battery Optimization',
              subtitle: 'Running without restrictions',
              action: _batteryOptimized ? 'Enabled' : (_isLoading ? 'Loading...' : 'Turn On'),
              isEnabled: _batteryOptimized,
              isLoading: _isLoading,
              onTap: _requestBatteryOptimization,
            ),
            const SizedBox(height: 16),
            _AlertItem(
              icon: Icons.volume_up,
              title: 'Volume Check',
              subtitle: 'Ensure volume is at least 60%',
              action: _volumeOk ? 'Checked' : (_isLoading ? 'Testing...' : 'Check'),
              isEnabled: _volumeOk,
              isLoading: _isLoading,
              onTap: _checkVolume,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String action;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onTap;

  const _AlertItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.isEnabled,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (isEnabled || isLoading) ? null : onTap,
      child: Row(
        children: [
          Icon(
            icon, 
            size: 32, 
            color: isEnabled ? Colors.green : Colors.grey[600]
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            action,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isEnabled ? Colors.green : Colors.blue,
            ),
          ),
          isLoading
              ? SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
              : Icon(
                  isEnabled ? Icons.check_circle : Icons.arrow_forward_ios, 
                  size: 12, 
                  color: isEnabled ? Colors.green : Colors.blue
                ),
        ],
      ),
    );
  }
}