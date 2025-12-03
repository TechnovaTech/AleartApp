import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/api_service.dart';

class MandateApprovalScreen extends StatefulWidget {
  const MandateApprovalScreen({Key? key}) : super(key: key);

  @override
  State<MandateApprovalScreen> createState() => _MandateApprovalScreenState();
}

class _MandateApprovalScreenState extends State<MandateApprovalScreen> {
  late WebViewController controller;
  bool isLoading = true;
  String? approvalUrl;
  String? mandateId;

  @override
  void initState() {
    super.initState();
    
    // Get arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          approvalUrl = args['approvalUrl'];
          mandateId = args['mandateId'];
        });
        _initializeWebView();
      }
    });
  }

  void _initializeWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            
            // Check if mandate approval is complete
            if (url.contains('success') || url.contains('approved')) {
              _handleMandateApproval();
            }
          },
        ),
      );
    
    // Load mock approval page
    _loadMockApprovalPage();
  }

  void _loadMockApprovalPage() {
    final mockHtml = '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Mandate Approval</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body { font-family: Arial, sans-serif; padding: 20px; background: #f5f5f5; }
            .container { max-width: 400px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .logo { text-align: center; margin-bottom: 30px; }
            .amount { font-size: 24px; font-weight: bold; color: #2196F3; text-align: center; margin: 20px 0; }
            .btn { width: 100%; padding: 15px; background: #2196F3; color: white; border: none; border-radius: 5px; font-size: 16px; cursor: pointer; margin: 10px 0; }
            .btn:hover { background: #1976D2; }
            .btn.cancel { background: #f44336; }
            .btn.cancel:hover { background: #d32f2f; }
            .info { background: #e3f2fd; padding: 15px; border-radius: 5px; margin: 20px 0; font-size: 14px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="logo">
                <h2>🏦 Mock Bank</h2>
                <p>Autopay Mandate Approval</p>
            </div>
            
            <div class="info">
                <strong>AlertPe</strong> is requesting permission to automatically debit your account for subscription payments.
            </div>
            
            <div class="amount">₹299/month</div>
            
            <button class="btn" onclick="approve()">Approve Mandate</button>
            <button class="btn cancel" onclick="reject()">Reject</button>
            
            <div style="margin-top: 20px; font-size: 12px; color: #666; text-align: center;">
                This is a mock approval page for testing purposes.
            </div>
        </div>
        
        <script>
            function approve() {
                window.location.href = 'https://mock-success.com/approved?mandate_id=${mandateId ?? 'mock_mandate'}';
            }
            
            function reject() {
                window.location.href = 'https://mock-success.com/rejected?mandate_id=${mandateId ?? 'mock_mandate'}';
            }
        </script>
    </body>
    </html>
    ''';
    
    controller.loadHtmlString(mockHtml);
  }

  Future<void> _handleMandateApproval() async {
    try {
      await ApiService.post('/mock-razorpay/mandate-link', {
        'mandateId': mandateId,
        'status': 'approved',
      });
      
      // Show success and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mandate approved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacementNamed(context, '/subscription-status');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approve Autopay'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          if (approvalUrl != null)
            WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}