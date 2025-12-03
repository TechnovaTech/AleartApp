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
        
        if (paymentUrl != null) {
          // Launch Razorpay payment page
          await RazorpayService.openCheckout(
            subscriptionId: response['subscriptionId'] ?? '',
            shortUrl: paymentUrl,
            amount: widget.planAmount,
            onSuccess: (result) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment page opened successfully!')),
              );
              Navigator.pushReplacementNamed(context, '/subscription-status');
            },
            onError: (error) {
              _showRetryDialog('Failed to open payment: ${error['error']}');
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
        title: const Text('Setup Failed'),
        content: Text('UPI Autopay setup failed: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _activateAutopay();
            },
            child: const Text('Retry'),
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

                  // Payment Methods
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Methods Available:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentMethod(Icons.account_balance_wallet, 'UPI (PhonePe, GPay, Paytm)', 'Instant payment'),
                        _buildPaymentMethod(Icons.credit_card, 'Credit/Debit Cards', 'Visa, Mastercard, RuPay'),
                        _buildPaymentMethod(Icons.account_balance, 'Net Banking', 'All major banks'),
                        _buildPaymentMethod(Icons.wallet, 'Wallets', 'Paytm, PhonePe, Amazon Pay'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Setup Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Process:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('1. Click "Pay Now" below'),
                        Text('2. Razorpay payment page will open'),
                        Text('3. Choose your preferred payment method'),
                        Text('4. Complete the payment securely'),
                        Text('5. Your subscription will be activated'),
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