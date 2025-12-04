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
      height: MediaQuery.of(context).size.height * 0.7,
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: Colors.blue, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Choose UPI App',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select your UPI app to setup autopay for ${widget.plan.name}',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Plan Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.blue.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.trialConfig['trialDurationDays']} Day Free Trial',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'Then ₹${widget.plan.price.toInt()}/${widget.plan.duration}',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Verification: ₹${widget.trialConfig['mandateVerificationAmount']}',
                          style: TextStyle(fontSize: 12, color: Colors.orange.shade600),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // UPI Apps List
                  Expanded(
                    child: ListView.builder(
                      itemCount: upiApps.length,
                      itemBuilder: (context, index) {
                        final app = upiApps[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.payment, color: Colors.blue, size: 28),
                            title: Text(
                              app['name']!,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            subtitle: const Text('Tap to setup autopay'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _selectUpiApp(app),
                          ),
                        );
                      },
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
  
  Future<void> _selectUpiApp(Map<String, String> app) async {
    Navigator.pop(context);
    
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
        throw Exception(trialResponse['message'] ?? 'Failed to start trial');
      }

      // Step 2: Create mandate
      final mandateResponse = await ApiService.post('/razorpay/create-mandate', {
        'userId': widget.userId,
        'planId': widget.plan.id,
        'amount': widget.plan.price,
        'verificationAmount': widget.trialConfig['mandateVerificationAmount'],
      });

      if (mandateResponse['success'] != true) {
        throw Exception(mandateResponse['message'] ?? 'Failed to create mandate');
      }

      // Step 3: Open UPI app
      await _openUpiApp(app, mandateResponse);

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