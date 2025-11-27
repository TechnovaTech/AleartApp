import 'dart:async';
import 'dart:math';
import 'api_service.dart';

class DemoPaymentService {
  static Timer? _timer;
  static bool _isRunning = false;
  
  static final List<Map<String, String>> _demoPayments = [
    {'amount': '150', 'app': 'Google Pay', 'name': 'Rahul Kumar', 'upi': 'rahul@oksbi'},
    {'amount': '250', 'app': 'PhonePe', 'name': 'Priya Sharma', 'upi': 'priya@ybl'},
    {'amount': '500', 'app': 'Paytm', 'name': 'Amit Singh', 'upi': 'amit@paytm'},
    {'amount': '75', 'app': 'BHIM UPI', 'name': 'Sneha Patel', 'upi': 'sneha@sbi'},
    {'amount': '300', 'app': 'Amazon Pay', 'name': 'Vikash Gupta', 'upi': 'vikash@axl'},
    {'amount': '125', 'app': 'Google Pay', 'name': 'Ravi Verma', 'upi': 'ravi@paytm'},
    {'amount': '450', 'app': 'PhonePe', 'name': 'Anjali Das', 'upi': 'anjali@ybl'},
  ];
  
  static void startDemo() {
    if (_isRunning) return;
    
    _isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 15), (timer) async {
      await _generateRandomPayment();
    });
  }
  
  static void stopDemo() {
    _timer?.cancel();
    _isRunning = false;
  }
  
  static Future<void> _generateRandomPayment() async {
    final random = Random();
    final payment = _demoPayments[random.nextInt(_demoPayments.length)];
    
    await ApiService.savePayment(
      amount: double.parse(payment['amount']!),
      paymentApp: payment['app']!,
      upiId: payment['upi']!,
      transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      notificationText: 'Demo payment via ${payment['app']}',
    );
  }
  
  static bool get isRunning => _isRunning;
}