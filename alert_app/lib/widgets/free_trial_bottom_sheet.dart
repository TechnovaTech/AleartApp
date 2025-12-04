import 'package:flutter/material.dart';
import '../models/plan.dart';
import '../services/api_service.dart';
import '../services/razorpay_service.dart';
import '../services/upi_app_detection_service.dart';

class FreeTrialBottomSheet extends StatefulWidget {
  final Plan plan;
  final Map<String, dynamic> trialConfig;
  final String userId;

  const FreeTrialBottomSheet({
    Key? key,
    required this.plan,
    required this.trialConfig,
    required this.userId,
  }) : super(key: key);

  @override
  State<FreeTrialBottomSheet> createState() => _FreeTrialBottomSheetState();
}

class _FreeTrialBottomSheetState extends State<FreeTrialBottomSheet> {
  bool isLoading = false;
  List<Map<String, String>> upiApps = [];

  @override
  void initState() {
    super.initState();
    _loadUpiApps();
  }

  Future<void> _loadUpiApps() async {
    final apps = await UpiAppDetectionService.getInstalledUpiApps();
    setState(() {
      upiApps = apps;
    });
  }





  Future<void> _openUpiApp(Map<String, String> app, Map<String, dynamic> mandateData) async {
    Navigator.pop(context);
    
    // Show confirmation dialog with real amount
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payment, color: Colors.blue),
            SizedBox(width: 8),
            Text('Setup Autopay'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your 7 day free trial is starting!'),
            SizedBox(height: 12),
            Text('Selected UPI App: ${app['name']}'),
            Text('Plan: ₹${widget.plan.price.toInt()}/${widget.plan.duration}'),
            SizedBox(height: 12),
            Text('Next steps:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('1. Your UPI app will open'),
            Text('2. Approve the autopay mandate'),
            Text('(₹${mandateData['amount']} for verification)'),
            Text('3. Enjoy your free trial!'),
            Text('4. Autopay starts after trial ends'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Skip for Now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Open ${app['name']}'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await RazorpayService.openMandateApproval(
          mandateUrl: mandateData['mandateUrl'],
          mandateId: mandateData['mandateId'],
          upiApp: app['packageName'],
          onSuccess: (result) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening ${app['name']} for mandate approval...'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacementNamed(context, '/home');
          },
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to open ${app['name']}: ${error['error']}'),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Try Browser',
                  onPressed: () => _openInBrowser(mandateData),
                ),
              ),
            );
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _openInBrowser(Map<String, dynamic> mandateData) async {
    try {
      await RazorpayService.openMandateApproval(
        mandateUrl: mandateData['browserUrl'] ?? mandateData['mandateUrl'],
        mandateId: mandateData['mandateId'],
        upiApp: null,
        onSuccess: (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Browser opened! Complete the ₹${mandateData['amount']} verification.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/home');
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to open browser: ${error['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Browser error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade400, Colors.green.shade600],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.timer, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Your Free Trial',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${widget.trialConfig['trialDurationDays']} days completely free',
                            style: TextStyle(fontSize: 16, color: Colors.green.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Plan Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade50, Colors.blue.shade100],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.blue.shade600),
                            const SizedBox(width: 8),
                            Text(
                              widget.plan.name,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              '₹${widget.plan.price.toInt()}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            Text(
                              '/${widget.plan.duration}',
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...widget.plan.features.map((feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(feature, style: const TextStyle(fontSize: 15)),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Verification Info
                  if (widget.trialConfig['isMandateVerificationEnabled'] == true) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.verified_user, color: Colors.orange.shade600),
                              const SizedBox(width: 8),
                              const Text(
                                'Account Verification',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Verification amount: ₹${widget.trialConfig['mandateVerificationAmount']} (refunded instantly)',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Explanation
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'How it works:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text('• Click "Start Trial" to begin your free trial'),
                        const Text('• Choose your preferred UPI app for autopay setup'),
                        const Text('• Complete verification payment (refunded instantly)'),
                        Text('• Enjoy premium features for ${widget.trialConfig['trialDurationDays']} days'),
                        const Text('• Cancel anytime during trial period'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Start Trial Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _startTrialAndOpenUpiChooser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: isLoading
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
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          : const Text(
                              'Start Free Trial',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _startTrialAndOpenUpiChooser() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Step 1: Start trial
      final trialResponse = await ApiService.post('/subscription/start-trial', {
        'userId': widget.userId,
        'planId': widget.plan.id,
        'trialDays': widget.trialConfig['trialDurationDays'],
        'planAmount': widget.plan.price,
      });

      if (trialResponse['success'] != true) {
        throw Exception(trialResponse['message'] ?? trialResponse['error'] ?? 'Failed to start trial');
      }

      // Step 2: Create mandate
      final mandateResponse = await ApiService.post('/razorpay/create-mandate', {
        'userId': widget.userId,
        'planId': widget.plan.id,
        'amount': widget.plan.price,
        'verificationAmount': widget.trialConfig['mandateVerificationAmount'],
      });

      if (mandateResponse['success'] != true) {
        throw Exception(mandateResponse['message'] ?? mandateResponse['error'] ?? 'Failed to create mandate');
      }

      // Step 3: Close popup and open system UPI chooser
      Navigator.pop(context);
      
      await RazorpayService.openMandateApproval(
        mandateUrl: mandateResponse['mandateUrl'],
        mandateId: mandateResponse['mandateId'],
        upiApp: null, // Let system choose like upgrade plan flow
        onSuccess: (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Complete ₹${mandateResponse['amount']} verification in your UPI app'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}