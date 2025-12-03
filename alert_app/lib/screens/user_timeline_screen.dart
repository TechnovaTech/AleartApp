import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserTimelineScreen extends StatefulWidget {
  const UserTimelineScreen({Key? key}) : super(key: key);

  @override
  State<UserTimelineScreen> createState() => _UserTimelineScreenState();
}

class _UserTimelineScreenState extends State<UserTimelineScreen> {
  List<dynamic> timelineEvents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTimeline();
  }

  Future<void> _loadTimeline() async {
    try {
      final userData = await ApiService.getCachedUserData();
      if (userData != null) {
        final response = await ApiService.get('/timeline/add?userId=${userData['_id']}');
        if (response['success']) {
          setState(() {
            timelineEvents = response['timeline'];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  IconData _getEventIcon(String eventType) {
    switch (eventType) {
      case 'registration':
        return Icons.person_add;
      case 'trial_started':
        return Icons.play_circle;
      case 'subscription_created':
        return Icons.card_membership;
      case 'payment_received':
        return Icons.payment;
      case 'mandate_approved':
        return Icons.check_circle;
      case 'subscription_renewed':
        return Icons.refresh;
      case 'subscription_expired':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'registration':
        return Colors.blue;
      case 'trial_started':
        return Colors.purple;
      case 'subscription_created':
        return Colors.green;
      case 'payment_received':
        return Colors.orange;
      case 'mandate_approved':
        return Colors.teal;
      case 'subscription_renewed':
        return Colors.indigo;
      case 'subscription_expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Timeline'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : timelineEvents.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timeline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No activity yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: timelineEvents.length,
                  itemBuilder: (context, index) {
                    final event = timelineEvents[index];
                    final isLast = index == timelineEvents.length - 1;
                    
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline indicator
                        Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getEventColor(event['eventType']),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getEventIcon(event['eventType']),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 60,
                                color: Colors.grey.withOpacity(0.3),
                              ),
                          ],
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Event content
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (event['description'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    event['description'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                  DateTime.parse(event['timestamp'])
                                      .toLocal()
                                      .toString()
                                      .split('.')[0],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}