import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SubscriptionFailureScreen extends StatefulWidget {
  final String failureReason;
  
  const SubscriptionFailureScreen({
    Key? key,
    required this.failureReason,
  }) : super(key: key);

  @override
  State<SubscriptionFailureScreen> createState() => _SubscriptionFailureScreenState();
}

class _SubscriptionFailureScreenState extends State<SubscriptionFailureScreen> {
  bool isRetrying = false;

  Future<void> _retrySubscription() async {
    setState(() {
      isRetrying = true;
    });

    try {
      // Navigate to subscription screen to retry
      Navigator.pushReplacementNamed(context, '/subscription');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isRetrying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription Issue'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
            ),
            
            SizedBox(height: 32),
            
            // Title
            Text(
              'Subscription Renewal Failed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 16),
            
            // Description
            Text(
              'Your subscription renewal failed and you have been downgraded to the free plan.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 16),
            
            // Failure Reason
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reason:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.failureReason,
                    style: TextStyle(
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            
            // Retry Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isRetrying ? null : _retrySubscription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isRetrying
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Retry Subscription',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Continue with Free Plan
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(
                'Continue with Free Plan',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, String failureReason) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionFailureScreen(
          failureReason: failureReason,
        ),
      ),
    );
  }
}