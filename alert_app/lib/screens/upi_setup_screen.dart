import 'package:flutter/material.dart';
import '../services/upi_app_detection_service.dart';
import '../services/razorpay_service.dart';
import '../services/api_service.dart';
import '../services/device_compatibility_service.dart';

class UpiSetupScreen extends StatefulWidget {
  final String userId;
  final String planId;
  final double? planAmount;
  
  const UpiSetupScreen({
    Key? key,
    required this.userId,
    required this.planId,
    this.planAmount,
  }) : super(key: key);

  @override
  State<UpiSetupScreen> createState() => _UpiSetupScreenState();
}

class _UpiSetupScreenState extends State<UpiSetupScreen> {
  List<Map<String, String>> installedApps = [];
  Map<String, String>? selectedApp;
  final TextEditingController _upiIdController = TextEditingController();
  bool isLoading = true;
  bool isProcessing = false;
  bool showManualEntry = false;
  bool isProblematicDevice = false;
  Map<String, String> deviceInstructions = {};

  @override
  void initState() {
    super.initState();
    _detectUpiApps();
  }

  Future<void> _detectUpiApps() async {
    setState(() {
      // Show top 4 UPI apps directly
      installedApps = [
        {'name': 'PhonePe', 'packageName': 'com.phonepe.app'},
        {'name': 'Google Pay', 'packageName': 'com.google.android.apps.nfc.payment'},
        {'name': 'Paytm', 'packageName': 'net.one97.paytm'},
        {'name': 'BHIM', 'packageName': 'in.org.npci.upiapp'},
      ];
      selectedApp = installedApps.first;
      showManualEntry = false;
      isLoading = false;
    });
  }



  Future<void> _activateAutopay() async {
    if (showManualEntry && !UpiAppDetectionService.isValidUpiId(_upiIdController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid UPI ID')),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      // Create real Razorpay subscription
      final response = await RazorpayService.createSubscription(
        userId: widget.userId,
        planId: widget.planId,
        amount: widget.planAmount,
      );

      if (response['success']) {
        final paymentUrl = response['shortUrl'] ?? response['paymentUrl'];
        
        final upiLink = response['upiLink'] ?? response['shortUrl'];
        
        if (upiLink != null) {
          // Launch payment with selected UPI app
          final specificApp = selectedApp?['packageName'];
          
          await RazorpayService.openCheckout(
            subscriptionId: response['subscriptionId'] ?? '',
            shortUrl: upiLink,
            specificApp: specificApp,
            amount: widget.planAmount,
            onSuccess: (result) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${selectedApp?['name'] ?? 'Payment app'} opened! Complete payment to activate subscription.'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
              // Don't navigate immediately, let user complete payment
            },
            onError: (error) {
              // Try opening in browser as fallback
              _showRetryDialog('UPI app failed to open. Try again or use browser payment.');
            },
          );
        } else {
          _showRetryDialog('No payment URL received');
        }
      } else {
        _showRetryDialog(response['error'] ?? 'Failed to create subscription');
      }
    } catch (e) {
      _showRetryDialog('Network error: $e');
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<void> _launchSpecificUpiApp(Map<String, String> app, String shortUrl) async {
    try {
      final packageName = app['packageName']!;
      final appName = app['name']!;
      
      await RazorpayService.openCheckout(
        subscriptionId: '',
        shortUrl: shortUrl,
        specificApp: packageName,
        amount: widget.planAmount,
        onSuccess: (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Autopay activated via $appName!')),
          );
          Navigator.pushReplacementNamed(context, '/subscription-status');
        },
        onError: (error) {
          _showRetryDialog('Failed to activate autopay via $appName: ${error['error']}');
        },
      );
    } catch (e) {
      _showRetryDialog('Failed to launch ${app['name']}: $e');
    }
  }

  Future<void> _launchGenericUpiIntent(String shortUrl) async {
    try {
      await RazorpayService.openCheckout(
        subscriptionId: '',
        shortUrl: shortUrl,
        amount: widget.planAmount,
        onSuccess: (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Autopay activated successfully!')),
          );
          Navigator.pushReplacementNamed(context, '/subscription-status');
        },
        onError: (error) {
          _showRetryDialog(error['error']);
        },
      );
    } catch (e) {
      _showRetryDialog(e.toString());
    }
  }

  void _showRetryDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment App Issue'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Try opening in browser
              final response = await RazorpayService.createSubscription(
                userId: widget.userId,
                planId: widget.planId,
                amount: widget.planAmount,
              );
              if (response['success'] && response['paymentUrl'] != null) {
                await RazorpayService.openCheckout(
                  subscriptionId: '',
                  shortUrl: response['paymentUrl'],
                  onSuccess: (result) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment page opened in browser!')),
                    );
                  },
                  onError: (error) {},
                );
              }
            },
            child: const Text('Open in Browser'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _activateAutopay();
            },
            child: const Text('Retry UPI App'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup UPI Autopay'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.payment, size: 48, color: Colors.blue),
                        const SizedBox(height: 12),
                        const Text(
                          'Razorpay Payment',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pay ₹${widget.planAmount ?? 99} securely with Razorpay',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // UPI App Selection
                  if (installedApps.isNotEmpty) ...[
                    const Text(
                      'Select Payment App',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    
                    ...installedApps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final app = entry.value;
                      final isSelected = selectedApp == app;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: RadioListTile<Map<String, String>>(
                          value: app,
                          groupValue: selectedApp,
                          onChanged: (value) {
                            setState(() {
                              selectedApp = value;
                            });
                          },
                          title: Row(
                            children: [
                              Icon(
                                Icons.payment,
                                color: isSelected ? Colors.blue : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(app['name']!),
                              if (index == 0) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.star, color: Colors.orange, size: 16),
                              ],
                            ],
                          ),
                          subtitle: Text(
                            index == 0 ? 'Recommended' : 'Available',
                            style: TextStyle(
                              color: isSelected ? Colors.blue : Colors.grey,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    
                    const SizedBox(height: 16),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'No UPI apps found. Payment will open in browser.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 32),

                  // Setup Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Process:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('1. Select your preferred UPI app above'),
                        const Text('2. Click "Pay Now" below'),
                        Text('3. ${selectedApp?['name'] ?? 'Payment app'} will open'),
                        const Text('4. Complete the payment securely'),
                        const Text('5. Your subscription will be activated'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Activate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isProcessing ? null : _activateAutopay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Pay ₹${widget.planAmount ?? 99} - Secure Payment',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentMethod(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    super.dispose();
  }
}