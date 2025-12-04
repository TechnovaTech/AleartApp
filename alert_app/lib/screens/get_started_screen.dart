import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/plan.dart';
import '../widgets/language_button.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  bool isLoading = true;
  bool isStartingTrial = false;
  List<Plan> plans = [];
  Map<String, dynamic>? trialConfig;
  Plan? selectedPlan;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load plans and trial config
      final [plansResult, trialResult] = await Future.wait([
        ApiService.getPlans(),
        ApiService.get('/config/trial'),
      ]);

      if (plansResult['success'] == true && plansResult['plans'] != null) {
        final plansList = (plansResult['plans'] as List)
            .map((planJson) => Plan.fromJson(planJson))
            .where((plan) => plan.isActive && plan.monthlyPrice > 0)
            .toList();
        
        setState(() {
          plans = plansList;
          selectedPlan = plansList.isNotEmpty ? plansList.first : null;
        });
      }

      if (trialResult['success'] == true) {
        setState(() {
          trialConfig = trialResult['config'];
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      _setFallbackData();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _setFallbackData() {
    setState(() {
      plans = [
        Plan(
          id: 'premium',
          name: 'Premium Plan',
          monthlyPrice: 99,
          yearlyPrice: 999,
          features: [
            'Unlimited UPI payment alerts',
            'Real-time SMS monitoring',
            'Advanced analytics & reports',
            'Custom notification sounds',
            'Priority customer support',
            'Multi-device sync',
            'Ad-free experience',
          ],
          isActive: true,
        ),
      ];
      selectedPlan = plans.first;
      trialConfig = {
        'trialDurationDays': 1,
        'isTrialEnabled': true,
        'trialFeatures': ['Basic alerts', 'Limited reports']
      };
    });
  }

  Future<void> _startFreeTrial() async {
    if (selectedPlan == null) return;

    setState(() {
      isStartingTrial = true;
    });

    try {
      final userData = await ApiService.getCachedUserData();
      if (userData == null) {
        _showLoginRequired();
        return;
      }

      // Start free trial with autopay setup
      final response = await ApiService.post('/subscription/start-trial', {
        'planId': selectedPlan!.id,
        'userId': userData['id'] ?? userData['_id'],
        'trialDays': trialConfig?['trialDurationDays'] ?? 1,
        'planAmount': selectedPlan!.monthlyPrice,
      });

      if (response['success'] == true) {
        // Navigate to UPI setup for autopay
        Navigator.pushNamed(
          context,
          '/upi-setup',
          arguments: {
            'userId': userData['id'] ?? userData['_id'],
            'planId': selectedPlan!.id,
            'planAmount': selectedPlan!.monthlyPrice,
            'isTrialMode': true,
            'trialDays': trialConfig?['trialDurationDays'] ?? 1,
          },
        );
      } else {
        _showError(response['message'] ?? 'Failed to start trial');
      }
    } catch (e) {
      _showError('Error starting trial: $e');
    } finally {
      setState(() {
        isStartingTrial = false;
      });
    }
  }

  void _showLoginRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to start your free trial.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [LanguageButton()],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.purple.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.rocket_launch,
                          color: Colors.white,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Welcome to AlertPe',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Smart UPI Payment Monitoring',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Free Trial Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.timer, color: Colors.green.shade600),
                            const SizedBox(width: 8),
                            Text(
                              '${trialConfig?['trialDurationDays'] ?? 1} Day FREE Trial',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try all premium features for free!',
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Selected Plan Card
                  if (selectedPlan != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade200, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
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
                                    selectedPlan!.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₹${selectedPlan!.monthlyPrice.toInt()}',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const Text(
                                        '/month',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Recommended',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Features
                          ...selectedPlan!.features.map((feature) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        feature,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Autopay Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.security, color: Colors.blue.shade600),
                              const SizedBox(width: 8),
                              Text(
                                'Secure Autopay Setup',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Free trial starts immediately\n• Autopay activates after trial ends\n• Cancel anytime during trial\n• Secure UPI mandate setup',
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Start Free Trial Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isStartingTrial ? null : _startFreeTrial,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: isStartingTrial
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Starting Trial...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Start Free Trial & Setup Autopay',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Terms
                    Text(
                      'By continuing, you agree to setup autopay for ₹${selectedPlan!.monthlyPrice.toInt()}/month after your free trial ends. Cancel anytime.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Alternative Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        child: const Text('Already have account?'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/plans'),
                        child: const Text('View all plans'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}