import 'package:flutter/material.dart';
import '../services/upi_app_detection_service.dart';
import '../services/razorpay_service.dart';
import '../services/api_service.dart';
import '../services/device_compatibility_service.dart';

class UpiSetupScreen extends StatefulWidget {
  final String userId;
  final String planId;
  final double? planAmount;
  final bool isTrialMode;
  final int? trialDays;
  final double? verificationAmount;
  
  const UpiSetupScreen({
    Key? key,
    required this.userId,
    required this.planId,
    this.planAmount,
    this.isTrialMode = false,
    this.trialDays,
    this.verificationAmount,
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
    try {
      // Always show common UPI apps for user selection
      final commonApps = [
        {'name': 'PhonePe', 'packageName': 'com.phonepe.app'},
        {'name': 'Google Pay', 'packageName': 'com.google.android.apps.nfc.payment'},
        {'name': 'GPay', 'packageName': 'com.google.android.apps.walletnfcrel'},
        {'name': 'Paytm', 'packageName': 'net.one97.paytm'},
        {'name': 'BHIM', 'packageName': 'in.org.npci.upiapp'},
        {'name': 'Amazon Pay', 'packageName': 'in.amazon.mShop.android.shopping'},
      ];
      
      setState(() {
        installedApps = commonApps;
        selectedApp = commonApps.first; // Default to PhonePe
        showManualEntry = false;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        installedApps = [
          {'name': 'PhonePe', 'packageName': 'com.phonepe.app'},
          {'name': 'Paytm', 'packageName': 'net.one97.paytm'},
        ];
        selectedApp = installedApps.first;
        showManualEntry = false;
        isLoading = false;
      });
    }
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
      if (widget.isTrialMode) {
        // Show autopay setup popup for trial mode
        _showAutopaySetupDialog();
      } else {
        // Create real Razorpay subscription for regular payment
        final response = await RazorpayService.createSubscription(
          userId: widget.userId,
          planId: widget.planId,
          amount: widget.planAmount,
        );

        if (response['success'] == true) {
          final upiLink = response['upiLink'] ?? response['shortUrl'];
          final paymentUrl = response['paymentUrl'];
          
          print('Payment response: $response');
          
          if (upiLink != null && upiLink.isNotEmpty) {
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
              },
              onError: (error) {
                _showRetryDialog('UPI app failed to open. Try browser payment.');
              },
            );
          } else {
            _showRetryDialog('Payment setup failed. Please try again.');
          }
        } else {
          final errorMsg = response['error'] ?? 'Unknown error occurred';
          _showRetryDialog('Setup failed: $errorMsg');
        }
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

  void _showAutopaySetupDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        Icon(Icons.payment, color: Colors.blue, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Setup UPI Mandate',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Plan Details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Plan Details:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text('Amount: ₹${widget.planAmount?.toInt() ?? 99}'),
                          Text('Trial: ${widget.trialDays ?? 1} day${(widget.trialDays ?? 1) > 1 ? 's' : ''} FREE'),
                          if (widget.verificationAmount != null)
                            Text('Verification: ₹${widget.verificationAmount!.toInt()} (refunded)'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // UPI Apps List
                    const Text(
                      'Select UPI App:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    
                    ...installedApps.map((app) {
                      final isSelected = selectedApp == app;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected ? Colors.blue.shade50 : Colors.white,
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.account_balance_wallet,
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                          title: Text(
                            app['name']!,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.blue : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            'Tap to select',
                            style: TextStyle(
                              color: isSelected ? Colors.blue.shade600 : Colors.grey,
                            ),
                          ),
                          trailing: isSelected 
                              ? Icon(Icons.check_circle, color: Colors.blue)
                              : null,
                          onTap: () {
                            setState(() {
                              selectedApp = app;
                            });
                          },
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 20),
                    
                    // Setup Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _setupRazorpayMandate();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Setup Mandate with ${selectedApp?['name'] ?? 'UPI App'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Skip Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: const Text('Skip for Now'),
                      ),
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

  Future<void> _setupRazorpayMandate() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Setting up Razorpay mandate...'),
          ],
        ),
      ),
    );

    try {
      // Create Razorpay mandate
      final mandateResponse = await RazorpayService.createMandate(
        userId: widget.userId,
        planId: widget.planId,
        amount: widget.planAmount ?? 99,
        verificationAmount: widget.verificationAmount,
        upiApp: selectedApp?['packageName'],
      );

      Navigator.pop(context); // Close loading dialog

      if (mandateResponse['success'] == true) {
        final mandateUrl = mandateResponse['mandateUrl'];
        final mandateId = mandateResponse['mandateId'];
        
        // Open UPI app or browser for mandate approval
        await RazorpayService.openMandateApproval(
          mandateUrl: mandateUrl,
          mandateId: mandateId,
          upiApp: selectedApp?['packageName'],
          onSuccess: (result) {
            _showMandateSuccess();
          },
          onError: (error) {
            _showMandateError(error['error'] ?? 'Mandate setup failed');
          },
        );
      } else {
        _showMandateError(mandateResponse['error'] ?? 'Failed to create mandate');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showMandateError('Network error: $e');
    }
  }

  void _showMandateSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            const Text('Mandate Setup Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your ${widget.trialDays ?? 1} day free trial is now active!',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text('UPI mandate has been set up successfully.'),
            const SizedBox(height: 8),
            Text(
              'Autopay will start after trial ends for ₹${widget.planAmount?.toInt() ?? 99}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Using App'),
          ),
        ],
      ),
    );
  }

  void _showMandateError(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mandate Setup Failed'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _setupRazorpayMandate();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
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
                      color: widget.isTrialMode ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          widget.isTrialMode ? Icons.timer : Icons.payment,
                          size: 48,
                          color: widget.isTrialMode ? Colors.green : Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.isTrialMode ? 'Free Trial + Autopay Setup' : 'Razorpay Payment',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.isTrialMode 
                              ? widget.verificationAmount != null
                                  ? 'Verify account with ₹${widget.verificationAmount!.toInt()} (refunded) + Setup autopay for ₹${widget.planAmount ?? 99}/month'
                                  : '${widget.trialDays ?? 1} day free trial, then ₹${widget.planAmount ?? 99}/month'
                              : 'Pay ₹${widget.planAmount ?? 99} securely with Razorpay',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // UPI App Selection
                  const Text(
                    'Select Payment App',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose your preferred UPI app:',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
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

                  const SizedBox(height: 32),

                  // Setup Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.isTrialMode ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isTrialMode ? 'Trial + Autopay Setup:' : 'Payment Process:',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (widget.isTrialMode) ...[
                          const Text('1. Select your preferred UPI app above'),
                          const Text('2. Click "Setup Autopay" below'),
                          Text('3. ${selectedApp?['name'] ?? 'Payment app'} will open'),
                          if (widget.verificationAmount != null) ...[
                            Text('4. Pay ₹${widget.verificationAmount!.toInt()} for verification'),
                            const Text('5. Amount will be refunded immediately'),
                            const Text('6. Approve UPI mandate for autopay'),
                            Text('7. Enjoy ${widget.trialDays ?? 1} day free trial!'),
                            const Text('8. Autopay starts after trial ends'),
                          ] else ...[
                            const Text('4. Approve the UPI mandate (₹0 for trial)'),
                            Text('5. Enjoy ${widget.trialDays ?? 1} day free trial!'),
                            const Text('6. Autopay starts after trial ends'),
                          ],
                        ] else ...[
                          const Text('1. Select your preferred UPI app above'),
                          const Text('2. Click "Pay Now" below'),
                          Text('3. ${selectedApp?['name'] ?? 'Payment app'} will open'),
                          const Text('4. Complete the payment securely'),
                          const Text('5. Your subscription will be activated'),
                        ],
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
                              widget.isTrialMode 
                                  ? widget.verificationAmount != null
                                      ? 'Verify & Setup Autopay - ₹${widget.verificationAmount!.toInt()}'
                                      : 'Setup Autopay - Start Free Trial'
                                  : 'Pay ₹${widget.planAmount ?? 99} - Secure Payment',
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