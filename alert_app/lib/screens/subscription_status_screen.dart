import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SubscriptionStatusScreen extends StatefulWidget {
  const SubscriptionStatusScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionStatusScreen> createState() => _SubscriptionStatusScreenState();
}

class _SubscriptionStatusScreenState extends State<SubscriptionStatusScreen> {
  Map<String, dynamic>? subscriptionData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    try {
      final userData = await ApiService.getCachedUserData();
      if (userData != null) {
        final response = await ApiService.get('/subscription/status?userId=${userData['_id']}');
        if (response['success']) {
          setState(() {
            subscriptionData = response;
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

  String _getStatusText(String status) {
    switch (status) {
      case 'trial':
        return 'Free Trial';
      case 'active':
        return 'Active';
      case 'expired':
        return 'Expired';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'trial':
        return Colors.blue;
      case 'active':
        return Colors.green;
      case 'expired':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Status'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : subscriptionData == null
              ? const Center(child: Text('No subscription found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Status Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              subscriptionData!['subscription']['status'] == 'active'
                                  ? Icons.check_circle
                                  : Icons.access_time,
                              size: 48,
                              color: _getStatusColor(subscriptionData!['subscription']['status']),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _getStatusText(subscriptionData!['subscription']['status']),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(subscriptionData!['subscription']['status']),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${subscriptionData!['subscription']['amount']}/month',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Details Cards
                      if (subscriptionData!['subscription']['trialEndDate'] != null)
                        _buildDetailCard(
                          'Trial Period',
                          'Ends on ${DateTime.parse(subscriptionData!['subscription']['trialEndDate']).toLocal().toString().split(' ')[0]}',
                          Icons.calendar_today,
                          Colors.blue,
                        ),
                      
                      if (subscriptionData!['subscription']['nextRenewalDate'] != null)
                        _buildDetailCard(
                          'Next Renewal',
                          DateTime.parse(subscriptionData!['subscription']['nextRenewalDate']).toLocal().toString().split(' ')[0],
                          Icons.refresh,
                          Colors.green,
                        ),
                      
                      // Mandate Status
                      if (subscriptionData!['mandate'] != null)
                        _buildDetailCard(
                          'Autopay Status',
                          _getStatusText(subscriptionData!['mandate']['status']),
                          Icons.credit_card,
                          _getStatusColor(subscriptionData!['mandate']['status']),
                        ),
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      if (subscriptionData!['subscription']['status'] == 'trial')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/subscription');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Upgrade Now',
                              style: TextStyle(
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

  Widget _buildDetailCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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