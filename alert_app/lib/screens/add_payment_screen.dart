import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _amountController = TextEditingController();
  final _payerNameController = TextEditingController();
  final _upiIdController = TextEditingController();
  String _selectedApp = 'Google Pay';
  bool _isLoading = false;

  final List<String> _paymentApps = [
    'Google Pay',
    'PhonePe',
    'Paytm',
    'BHIM UPI',
    'Amazon Pay',
    'Other'
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _payerNameController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  void _savePayment() async {
    final amount = _amountController.text.trim();
    final payerName = _payerNameController.text.trim();
    final upiId = _upiIdController.text.trim();

    if (amount.isEmpty || payerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await ApiService.getCachedUserData();
      if (userData != null) {
        final result = await ApiService.savePayment(
          amount: double.tryParse(amount) ?? 0.0,
          paymentApp: _selectedApp,
          upiId: upiId.isEmpty ? 'unknown@upi' : upiId,
          transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
          notificationText: 'Manual entry: ₹$amount via $_selectedApp',
        );

        if (result['success'] == true) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment added successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? 'Failed to save payment')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount *',
                hintText: 'Enter amount (without ₹)',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _payerNameController,
              decoration: const InputDecoration(
                labelText: 'Payer Name *',
                hintText: 'Enter payer name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _upiIdController,
              decoration: const InputDecoration(
                labelText: 'UPI ID (Optional)',
                hintText: 'user@paytm',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedApp,
              decoration: const InputDecoration(
                labelText: 'Payment App',
                border: OutlineInputBorder(),
              ),
              items: _paymentApps.map((app) {
                return DropdownMenuItem(
                  value: app,
                  child: Text(app),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedApp = value!;
                });
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _savePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Add Payment', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}