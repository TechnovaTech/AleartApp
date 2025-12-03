import 'package:flutter/material.dart';

class RenewalReminderNotification extends StatelessWidget {
  final String reminderType;
  final DateTime renewalDate;
  final VoidCallback? onDismiss;
  
  const RenewalReminderNotification({
    Key? key,
    required this.reminderType,
    required this.renewalDate,
    this.onDismiss,
  }) : super(key: key);

  String get _reminderText {
    switch (reminderType) {
      case '24h':
        return 'Your subscription renews in 24 hours';
      case '1h':
        return 'Your subscription renews in 1 hour';
      default:
        return 'Subscription renewal reminder';
    }
  }

  Color get _reminderColor {
    switch (reminderType) {
      case '24h':
        return Colors.blue;
      case '1h':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _reminderColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _reminderColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: _reminderColor,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _reminderText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _reminderColor,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Renewal Date: ${renewalDate.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(
                    color: _reminderColor.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: _reminderColor,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  static void showSnackBar(BuildContext context, String reminderType, DateTime renewalDate) {
    final notification = RenewalReminderNotification(
      reminderType: reminderType,
      renewalDate: renewalDate,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: notification,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: Duration(seconds: 5),
      ),
    );
  }
}