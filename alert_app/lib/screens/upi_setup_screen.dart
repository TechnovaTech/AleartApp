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
        final shortUrl = response['shortUrl'] ?? 'upi://pay?pa=merchant@razorpay&pn=AlertPe&tr=${DateTime.now().millisecondsSinceEpoch}&tn=Subscription&am=${widget.planAmount ?? 99}&cu=INR';
        
        // Launch specific UPI app or show options
        if (!showManualEntry && selectedApp != null) {
          await _launchSpecificUpiApp(selectedApp!, shortUrl);
        } else {
          await _launchGenericUpiIntent(shortUrl);
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
                    child: const Column(
                      children: [
                        Icon(Icons.account_balance_wallet, size: 48, color: Colors.blue),
                        SizedBox(height: 12),
                        Text(
                          'UPI Autopay Setup',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Set up automatic payments for your subscription',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (!showManualEntry) ...[
                    // UPI App Selection
                    const Text(
                      'Select UPI App',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Found ${installedApps.length} UPI apps on your device:',
                      style: const TextStyle(color: Colors.green, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    
                    ...installedApps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final app = entry.value;
                      final priority = index == 0 ? 'Highest Priority' : 
                                     index == 1 ? 'High Priority' : 'Available';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: index == 0 ? Colors.green : Colors.grey.shade300,
                            width: index == 0 ? 2 : 1,
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
                                color: index == 0 ? Colors.green : Colors.blue,
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
                            priority,
                            style: TextStyle(
                              color: index == 0 ? Colors.green : Colors.grey,
                              fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 16),
                    
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showManualEntry = true;
                        });
                      },
                      child: const Text('Enter UPI ID manually'),
                    ),
                  ],

                  if (showManualEntry) ...[
                    // Manual UPI ID Entry
                    const Text(
                      'Enter UPI ID',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: _upiIdController,
                      decoration: const InputDecoration(
                        hintText: 'username@paytm',
                        prefixIcon: Icon(Icons.account_balance_wallet),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    const Text(
                      'No UPI apps found on your device. Please enter your UPI ID manually.',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),

                    if (installedApps.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            showManualEntry = false;
                          });
                        },
                        child: const Text('Use installed UPI app'),
                      ),
                    ],
                  ],

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
                          'Setup Process:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('1. Click "Activate Autopay" below'),
                        Text('2. Your UPI app will open'),
                        Text('3. Authorize the mandate'),
                        Text('4. Your subscription will be activated'),
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
                          : const Text(
                              'Activate Autopay',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    super.dispose();
  }
}