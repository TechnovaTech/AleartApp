import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TrialBannerWidget extends StatefulWidget {
  final String userId;
  
  const TrialBannerWidget({Key? key, required this.userId}) : super(key: key);

  @override
  State<TrialBannerWidget> createState() => _TrialBannerWidgetState();
}

class _TrialBannerWidgetState extends State<TrialBannerWidget> {
  Map<String, dynamic>? subscriptionData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionStatus();
  }

  Future<void> _fetchSubscriptionStatus() async {
    try {
      final response = await ApiService.get('/subscription/status?userId=${widget.userId}');
      if (response['success']) {
        setState(() {
          subscriptionData = response;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  int _getDaysRemaining() {
    if (subscriptionData?['subscription']?['trialEndDate'] != null) {
      final trialEnd = DateTime.parse(subscriptionData!['subscription']['trialEndDate']);
      final now = DateTime.now();
      return trialEnd.difference(now).inDays;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox.shrink();
    }

    final subscription = subscriptionData?['subscription'];
    if (subscription == null || subscription['status'] != 'trial') {
      return const SizedBox.shrink();
    }

    final daysRemaining = _getDaysRemaining();
    if (daysRemaining <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.access_time,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Free Trial Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$daysRemaining days remaining',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/subscription');
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}