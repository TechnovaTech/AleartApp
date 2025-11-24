import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final notificationStatus = await Permission.notification.status;
    setState(() {
      _postNotifications = notificationStatus.isGranted;
    });
  }

  Future<void> _requestNotificationListener() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enable notification access in Settings')),
    );
    setState(() {
      _notificationAccess = true;
    });
  }

  Future<void> _requestPostNotifications() async {
    final status = await Permission.notification.request();
    setState(() {
      _postNotifications = status.isGranted;
    });
  }

  Future<void> _requestBatteryOptimization() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please disable battery optimization in Settings')),
    );
    setState(() {
      _batteryOptimized = true;
    });
  }

  Future<void> _checkVolume() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Volume checked - Please ensure it\'s above 60%')),
    );
    setState(() {
      _volumeOk = true;
    });
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
              action: _notificationAccess ? 'Enabled' : 'Turn On',
              isEnabled: _notificationAccess,
              onTap: _requestNotificationListener,
            ),
            const SizedBox(height: 16),
            _AlertItem(
              icon: Icons.music_note,
              title: 'Post Notifications',
              subtitle: 'Show payment alerts',
              action: _postNotifications ? 'Enabled' : 'Turn On',
              isEnabled: _postNotifications,
              onTap: _requestPostNotifications,
            ),
            const SizedBox(height: 16),
            _AlertItem(
              icon: Icons.battery_full,
              title: 'Battery Optimization',
              subtitle: 'Running without restrictions',
              action: _batteryOptimized ? 'Enabled' : 'Turn On',
              isEnabled: _batteryOptimized,
              onTap: _requestBatteryOptimization,
            ),
            const SizedBox(height: 16),
            _AlertItem(
              icon: Icons.volume_up,
              title: 'Volume Check',
              subtitle: 'Ensure volume is at least 60%',
              action: _volumeOk ? 'Checked' : 'Check',
              isEnabled: _volumeOk,
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
  final VoidCallback onTap;

  const _AlertItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? null : onTap,
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
          Icon(
            isEnabled ? Icons.check_circle : Icons.arrow_forward_ios, 
            size: 12, 
            color: isEnabled ? Colors.green : Colors.blue
          ),
        ],
      ),
    );
  }
}