import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/razorpay_service.dart';
import '../models/plan.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  bool isLoading = true;
  Plan? availablePlan;
  Map<String, dynamic>? trialConfig;
  Map<String, dynamic>? userSubscription;
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Get user data
      final userData = await ApiService.getCachedUserData();
      if (userData != null) {
        userId = userData['id'] ?? userData['_id'] ?? '';
        print('Loaded user ID: $userId');
      } else {
        print('No cached user data found');
        // If no cached data, try to get from navigation arguments
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        if (args != null && args['userId'] != null) {
          userId = args['userId'];
          print('Got user ID from navigation: $userId');
        }
      }

      // Load plans, trial config, and subscription status
      final [plansResult, trialResult, subscriptionResult] = await Future.wait([
        ApiService.get('/plans'),
        ApiService.get('/config/trial'),
        userId.isNotEmpty ? ApiService.get('/subscription/status?userId=$userId') : Future.value({'success': false}),
      ]);

      // Process plans
      if (plansResult['success'] == true && plansResult['plans'] != null) {
        final plansList = (plansResult['plans'] as List)
            .map((planJson) => Plan.fromJson(planJson))
            .where((plan) => plan.isActive && plan.price > 0)
            .toList();
        
        if (plansList.isNotEmpty) {
          availablePlan = plansList.first;
        }
      }

      // Process trial config
      if (trialResult['success'] == true) {
        trialConfig = trialResult['config'];
      }

      // Process subscription
      if (subscriptionResult['success'] == true) {
        userSubscription = subscriptionResult['subscription'];
      }

      // Set fallback data if needed
      if (availablePlan == null) {
        availablePlan = Plan(
          id: 'fallback',
          name: 'Premium Plan',
          price: 299,
          duration: 'monthly',
          features: [
            'Voice Alerts',
            'Unlimited Payment History',
            'Advanced Reports',
            'Autopay Enabled',
          ],
          isActive: true,
        );
      }

      if (trialConfig == null) {
        trialConfig = {
          'trialDurationDays': 7,
          'isTrialEnabled': true,
          'trialFeatures': ['Voice Alerts', 'Basic Reports'],
          'mandateVerificationAmount': 5,
          'isMandateVerificationEnabled': true,
        };
      }

    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getUserStatus() {
    if (userSubscription == null) return 'free';
    return userSubscription!['status'] ?? 'free';
  }

  Widget _buildCurrentPlanCard() {
    final status = _getUserStatus();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: status == 'free' 
                        ? [Colors.grey.shade400, Colors.grey.shade600]
                        : status == 'trial'
                            ? [Colors.green.shade400, Colors.green.shade600]
                            : [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  status == 'free' ? Icons.person : status == 'trial' ? Icons.timer : Icons.star,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCurrentPlanTitle(status),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCurrentPlanSubtitle(status),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrentPlanTitle(String status) {
    switch (status) {
      case 'trial':
        final daysLeft = _calculateTrialDaysLeft();
        return 'Your Trial is Active ($daysLeft days left)';
      case 'active':
        return 'Your Active Plan: Premium';
      case 'expired':
        return 'Your trial has ended';
      default:
        return 'Current Plan: Free Plan';
    }
  }

  String _getCurrentPlanSubtitle(String status) {
    switch (status) {
      case 'trial':
        return 'Premium features unlocked.';
      case 'active':
        return 'Renews on: ${_getNextRenewalDate()}';
      case 'expired':
        return 'Tap below to activate autopay and continue Premium services.';
      default:
        return 'Upgrade to unlock premium alerts, analytics & automation.';
    }
  }

  String _calculateTrialDaysLeft() {
    if (userSubscription?['trialEndDate'] != null) {
      final endDate = DateTime.parse(userSubscription!['trialEndDate']);
      final now = DateTime.now();
      final difference = endDate.difference(now).inDays;
      return difference > 0 ? difference.toString() : '0';
    }
    return '0';
  }

  String _getNextRenewalDate() {
    if (userSubscription?['nextRenewalDate'] != null) {
      final renewalDate = DateTime.parse(userSubscription!['nextRenewalDate']);
      return '${renewalDate.day}/${renewalDate.month}/${renewalDate.year}';
    }
    return 'N/A';
  }

  Widget _buildPlanDisplayCard() {
    if (availablePlan == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.diamond, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${availablePlan!.name} – ₹${availablePlan!.price.toInt()}/${availablePlan!.duration}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...availablePlan!.features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final status = _getUserStatus();
    
    if (status == 'trial') {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          child: const Text(
            'Continue to Dashboard',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    
    if (status == 'expired') {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/subscription'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          child: const Text(
            'Activate Autopay to Continue',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    
    if (status == 'active') {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          child: const Text(
            'Continue to Dashboard',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    
    // Default: Free user - show Start Free Trial
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showFreeTrialBottomSheet,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, size: 20),
            const SizedBox(width: 8),
            Text(
              'Start ${trialConfig?['trialDurationDays'] ?? 7} Day Free Trial',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showFreeTrialBottomSheet() {
    if (availablePlan == null || trialConfig == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to start your free trial'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Start trial and mandate creation directly
    _startTrialAndOpenUpiChooser();
  }
  
  Future<void> _startTrialAndOpenUpiChooser() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Setting up your trial...'),
            ],
          ),
        ),
      );

      print('Starting trial for user: $userId, plan: ${availablePlan!.id}');
      
      // Step 1: Start trial
      final trialResponse = await ApiService.post('/subscription/start-trial', {
        'userId': userId,
        'planId': availablePlan!.id,
        'trialDays': trialConfig!['trialDurationDays'],
        'planAmount': availablePlan!.price,
      });

      print('Trial response: $trialResponse');

      if (trialResponse['success'] != true) {
        throw Exception(trialResponse['message'] ?? trialResponse['error'] ?? 'Failed to start trial');
      }

      // Step 2: Create mandate
      print('Creating mandate for user: $userId');
      
      final mandateResponse = await ApiService.post('/razorpay/create-mandate', {
        'userId': userId,
        'planId': availablePlan!.id,
        'amount': availablePlan!.price,
        'verificationAmount': trialConfig!['mandateVerificationAmount'],
      });

      print('Mandate response: $mandateResponse');

      if (mandateResponse['success'] != true) {
        throw Exception(mandateResponse['message'] ?? mandateResponse['error'] ?? 'Failed to create mandate');
      }

      Navigator.pop(context); // Close loading dialog

      // Step 3: Open UPI app chooser directly
      await RazorpayService.openMandateApproval(
        mandateUrl: mandateResponse['mandateUrl'],
        mandateId: mandateResponse['mandateId'],
        upiApp: null, // Let system choose
        onSuccess: (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Trial started! Complete ₹${mandateResponse['amount']} verification in your UPI app.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/home');
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to open UPI app: ${error['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );

    } catch (e) {
      Navigator.pop(context); // Close loading dialog if open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Welcome to AlertPe ',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '👋',
                                style: TextStyle(fontSize: 28),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your smart UPI voice alert assistant',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Current Plan Card
                    _buildCurrentPlanCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Admin Panel Plan Display
                    _buildPlanDisplayCard(),
                    
                    const SizedBox(height: 32),
                    
                    // Action Button
                    _buildActionButton(),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}