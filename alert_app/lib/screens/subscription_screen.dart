import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/razorpay_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool isLoading = false;
  bool isLoadingPlans = true;
  List<Map<String, dynamic>> plans = [];
  int selectedPlanIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      print('Loading plans from API...');
      final response = await ApiService.get('/plans');
      print('Plans API response: $response');
      
      if (response['success'] && response['plans'] != null) {
        final plansList = List<Map<String, dynamic>>.from(response['plans']);
        print('Loaded ${plansList.length} plans from API');
        
        setState(() {
          plans = plansList;
          isLoadingPlans = false;
          if (plans.isNotEmpty) {
            selectedPlanIndex = 0;
          }
        });
      } else {
        print('API failed, using fallback plans');
        _useFallbackPlans();
      }
    } catch (e) {
      print('Error loading plans: $e');
      _useFallbackPlans();
    }
  }
  
  void _useFallbackPlans() {
    setState(() {
      plans = [
        {
          '_id': 'basic_plan',
          'name': 'Basic Plan',
          'price': 99,
          'duration': 'monthly',
          'features': ['SMS monitoring', 'Basic reports', 'Email support']
        },
        {
          '_id': 'premium_plan', 
          'name': 'Premium Plan',
          'price': 199,
          'duration': 'monthly',
          'features': ['Unlimited SMS monitoring', 'Advanced analytics', 'PDF reports', 'Priority support', 'No ads']
        },
      ];
      isLoadingPlans = false;
    });
  }

  Future<void> _startSubscription() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userData = await ApiService.getCachedUserData();
      if (userData == null) return;

      final selectedPlan = plans[selectedPlanIndex];
      
      // Navigate to UPI setup screen
      Navigator.pushNamed(
        context,
        '/upi-setup',
        arguments: {
          'userId': userData['id'] ?? userData['_id'],
          'planId': selectedPlan['_id'],
          'planAmount': selectedPlan['price'],
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start subscription: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoadingPlans
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Upgrade to Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Get unlimited access to all features',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Plan Selection
            if (plans.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                child: const Text('No plans available'),
              )
            else
              ...plans.asMap().entries.map((entry) {
                final index = entry.key;
                final plan = entry.value;
                final isSelected = selectedPlanIndex == index;
                final features = plan['features'] is List 
                    ? List<String>.from(plan['features']) 
                    : <String>[];
                
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ] : [],
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedPlanIndex = index;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              plan['name'] ?? 'Plan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.blue : Colors.grey[800],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: Colors.blue),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${plan['price'] ?? 0}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.blue : Colors.grey[800],
                              ),
                            ),
                            Text(
                              '/${plan['duration'] ?? 'month'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...features.map<Widget>((feature) => 
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check,
                                  size: 16,
                                  color: isSelected ? Colors.blue : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).toList(),
                      ],
                    ),
                  ),
                );
              }).toList(),
            
            // UPI Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UPI Autopay Options:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('✓ PhonePe (Recommended)'),
                  Text('✓ Google Pay'),
                  Text('✓ Paytm'),
                  Text('✓ BHIM & other UPI apps'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Subscribe Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _startSubscription,
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
                    : Text(
                        plans.isNotEmpty 
                            ? 'Setup UPI Autopay - ₹${plans[selectedPlanIndex]['price']}/month'
                            : 'Setup UPI Autopay',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            const Text(
              'Cancel anytime. No commitment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

