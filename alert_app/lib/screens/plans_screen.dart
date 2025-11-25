import 'package:flutter/material.dart';
import '../services/localization_service.dart';
import '../services/api_service.dart';
import '../models/plan.dart';
import '../widgets/language_button.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  String currentPlan = 'free';
  List<Plan> plans = [];
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    LocalizationService.loadLanguage().then((_) {
      if (mounted) setState(() {});
    });
    _loadPlans();
  }
  
  Future<void> _loadPlans() async {
    try {
      final result = await ApiService.getPlans();
      if (result['success'] == true && result['plans'] != null) {
        setState(() {
          plans = (result['plans'] as List)
              .map((planJson) => Plan.fromJson(planJson))
              .where((plan) => plan.isActive)
              .toList();
          isLoading = false;
        });
      } else {
        _setFallbackPlans();
      }
    } catch (e) {
      _setFallbackPlans();
    }
  }
  
  void _setFallbackPlans() {
    setState(() {
      plans = [
        Plan(
          id: 'free',
          name: 'Free Plan',
          monthlyPrice: 0,
          yearlyPrice: 0,
          features: [
            'Basic UPI payment alerts',
            'Up to 2 QR codes',
            'Standard notification sounds',
            'Email support',
          ],
          isActive: true,
        ),
        Plan(
          id: 'premium',
          name: 'Premium Plan',
          monthlyPrice: 99,
          yearlyPrice: 999,
          features: [
            'Advanced UPI payment alerts',
            'Unlimited QR codes',
            'Custom notification sounds',
            'Real-time transaction tracking',
            'Priority customer support',
            'Advanced analytics & reports',
            'Multi-device sync',
            'Ad-free experience',
          ],
          isActive: true,
        ),
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        title: Text(
          'Plans & Subscription',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: const [
          LanguageButton(),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Plan Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade800],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Current Plan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    currentPlan == 'free' ? 'Free Plan' : 'Premium Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    currentPlan == 'free' 
                        ? 'Basic UPI alerts with limited features'
                        : 'Full access to all premium features',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            Text(
              'Choose Your Plan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Dynamic Plan Cards
            ...plans.map((plan) => Column(
              children: [
                _PlanCard(
                  title: plan.name,
                  price: '₹${plan.monthlyPrice.toInt()}',
                  period: '/month',
                  features: plan.features,
                  isCurrentPlan: currentPlan == plan.id,
                  isPremium: plan.monthlyPrice > 0,
                  onTap: () {
                    if (currentPlan != plan.id) {
                      if (plan.monthlyPrice > 0) {
                        _showUpgradeDialog(plan);
                      } else {
                        _showDowngradeDialog();
                      }
                    }
                  },
                ),
                SizedBox(height: 16),
              ],
            )).toList(),
            
            SizedBox(height: 24),
            
            // Features Comparison
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why Upgrade to Premium?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  _FeatureRow('Unlimited QR codes', true),
                  _FeatureRow('Custom alert sounds', true),
                  _FeatureRow('Advanced analytics', true),
                  _FeatureRow('Priority support', true),
                  _FeatureRow('Ad-free experience', true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _PlanCard({
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isCurrentPlan,
    required bool isPremium,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentPlan ? Colors.blue : Colors.grey[300]!,
            width: isCurrentPlan ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isPremium ? Colors.blue : Colors.grey[600],
                          ),
                        ),
                        Text(
                          period,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isCurrentPlan)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Current',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: 16),
            
            ...features.map((feature) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: isPremium ? Colors.blue : Colors.grey[600],
                    size: 16,
                  ),
                  SizedBox(width: 8),
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
            )).toList(),
            
            if (!isCurrentPlan) ...[
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPremium ? Colors.blue : Colors.grey[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: onTap,
                  child: Text(
                    isPremium ? 'Upgrade Now' : 'Downgrade',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _FeatureRow(String feature, bool included) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            included ? Icons.check_circle : Icons.cancel,
            color: included ? Colors.green : Colors.red,
            size: 20,
          ),
          SizedBox(width: 12),
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
    );
  }

  void _showUpgradeDialog(Plan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upgrade to ${plan.name}'),
        content: Text('Unlock all premium features for just ₹${plan.monthlyPrice.toInt()}/month. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPurchase(plan);
            },
            child: Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _showDowngradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Downgrade to Free'),
        content: Text('You will lose access to premium features. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentPlan = 'free';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downgraded to Free Plan')),
              );
            },
            child: Text('Downgrade'),
          ),
        ],
      ),
    );
  }

  void _processPurchase(Plan plan) {
    // Simulate purchase process
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing payment...'),
          ],
        ),
      ),
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context);
      setState(() {
        currentPlan = plan.id;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully upgraded to ${plan.name}!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
}