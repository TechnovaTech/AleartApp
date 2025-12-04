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
    setState(() {
      isLoading = true;
    });
    
    try {
      // Load plans from production API
      final plansResponse = await ApiService.get('/plans');
      
      if (plansResponse['success'] == true && plansResponse['plans'] != null) {
        final plansList = (plansResponse['plans'] as List)
            .map((planJson) => Plan.fromJson(planJson))
            .where((plan) => plan.isActive && plan.price > 0)
            .toList();
        
        setState(() {
          plans = plansList;
          selectedPlan = plansList.isNotEmpty ? plansList.first : null;
        });
      }

      // Load trial configuration
      final trialResponse = await ApiService.get('/config/trial');
      
      if (trialResponse['success'] == true && trialResponse['config'] != null) {
        setState(() {
          trialConfig = trialResponse['config'];
        });
      }
      
      // If no data loaded, use fallback
      if (plans.isEmpty) {
        _setFallbackData();
      }
      
    } catch (e) {
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
          id: 'fallback_plan',
          name: 'Premium Plan',
          price: 99,
          duration: 'monthly',
          features: [
            'UPI payment monitoring',
            'SMS alerts',
            'Basic reports',
            'QR code generation',
            'Email support',
          ],
          isActive: true,
        ),
      ];
      selectedPlan = plans.first;
      trialConfig = {
        'trialDurationDays': 7,
        'isTrialEnabled': true,
        'trialFeatures': ['Basic alerts', 'Limited reports']
      };
    });
  }

  Future<void> _startFreeTrial() async {
    if (selectedPlan == null) return;
    _showTrialInformationPopup();
  }

  void _showTrialInformationPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        Icon(Icons.timer, color: Colors.green.shade600, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          '${trialConfig?['trialDurationDays'] ?? 1} Day Free Trial',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Plan Information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedPlan!.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${selectedPlan!.price.toInt()}/${selectedPlan!.duration}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Features included:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          ...selectedPlan!.features.take(3).map((feature) => 
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.check, color: Colors.green, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Trial Information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Trial Details:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('• ${trialConfig?['trialDurationDays'] ?? 1} day${(trialConfig?['trialDurationDays'] ?? 1) > 1 ? 's' : ''} completely FREE'),
                          const Text('• Full access to premium features'),
                          const Text('• No charges during trial period'),
                          Text('• Autopay starts after trial (₹${selectedPlan!.price.toInt()}/${selectedPlan!.duration})'),
                          const Text('• Cancel anytime during trial'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Mandate Verification Information
                    if (trialConfig?['isMandateVerificationEnabled'] == true) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.verified_user, color: Colors.purple.shade600),
                                const SizedBox(width: 8),
                                const Text(
                                  'Account Verification',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('• Pay ₹${trialConfig?['mandateVerificationAmount'] ?? 5} to verify account'),
                            const Text('• Amount will be immediately refunded'),
                            const Text('• Confirms your payment method'),
                            const Text('• Required for autopay setup'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Autopay Information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.security, color: Colors.orange.shade600),
                              const SizedBox(width: 8),
                              const Text(
                                'Autopay Setup Process',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (trialConfig?['isMandateVerificationEnabled'] == true)
                            Text('1. Verify account with ₹${trialConfig?['mandateVerificationAmount'] ?? 5} (refunded)')
                          else
                            const Text('1. Direct autopay setup'),
                          const Text('2. Setup UPI mandate'),
                          const Text('3. Trial starts immediately'),
                          Text('4. Autopay for ₹${selectedPlan!.price.toInt()}/${selectedPlan!.duration} after trial'),
                          const Text('5. Cancel anytime during trial'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _proceedWithTrialSetup();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Setup Autopay',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _proceedWithTrialSetup() async {
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
        'planAmount': selectedPlan!.price,
      });

      if (response['success'] == true) {
        // Navigate to UPI setup for autopay
        Navigator.pushNamed(
          context,
          '/upi-setup',
          arguments: {
            'userId': userData['id'] ?? userData['_id'],
            'planId': selectedPlan!.id,
            'planAmount': selectedPlan!.price,
            'isTrialMode': true,
            'trialDays': trialConfig?['trialDurationDays'] ?? 1,
            'verificationAmount': trialConfig?['isMandateVerificationEnabled'] == true 
                ? trialConfig?['mandateVerificationAmount']?.toDouble() 
                : null,
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
          : selectedPlan == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('No plans available'),
                      Text('Please check your connection'),
                    ],
                  ),
                )
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
                        child: const Column(
                          children: [
                            Icon(
                              Icons.rocket_launch,
                              color: Colors.white,
                              size: 64,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Welcome to AlertPe',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
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
                                  style: const TextStyle(
                                    color: Color(0xFF2E7D32),
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
                                          '₹${selectedPlan!.price.toInt()}',
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        Text(
                                          '/${selectedPlan!.duration}',
                                          style: const TextStyle(
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
                              : Text(
                                  'Start ${trialConfig?['trialDurationDays'] ?? 1} Day Trial',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Terms
                      Text(
                        'By continuing, you agree to setup autopay for ₹${selectedPlan!.price.toInt()}/${selectedPlan!.duration} after your free trial ends. Cancel anytime.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),

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