import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../services/api_service.dart';
import 'settings_screen.dart';
import 'language_popup.dart';

class MyQRScreen extends StatefulWidget {
  const MyQRScreen({super.key});

  @override
  State<MyQRScreen> createState() => _MyQRScreenState();
}

class _MyQRScreenState extends State<MyQRScreen> {
  final List<TextEditingController> _upiControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final PageController _pageController = PageController();
  List<bool> _qrGenerated = [false, false];
  List<String> _qrData = ['', ''];
  int _currentPage = 0;
  List<Map<String, dynamic>> _recentQRCodes = [];
  bool _isLoading = false;
  bool _showInstructions = false;

  @override
  void initState() {
    super.initState();
    _loadRecentQRCodes();
  }

  String _generateUPIQRData(String upiId) {
    return 'upi://pay?pa=$upiId&pn=AlertPe%20Soundbox&cu=INR';
  }

  bool _isValidUPI(String upiId) {
    return RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$').hasMatch(upiId);
  }

  Future<void> _loadRecentQRCodes() async {
    final userData = await ApiService.getCachedUserData();
    if (userData != null) {
      final result = await ApiService.getQRCodes(userId: userData['id']);
      if (result['qrCodes'] != null) {
        setState(() {
          _recentQRCodes = List<Map<String, dynamic>>.from(result['qrCodes']);
        });
      }
    }
  }

  Future<void> _saveQRCode(String upiId) async {
    final userData = await ApiService.getCachedUserData();
    if (userData != null) {
      await ApiService.saveQRCode(upiId: upiId, userId: userData['id']);
      _loadRecentQRCodes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final qrBoxSize = screenWidth - 32;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        automaticallyImplyLeading: false,
        title: Text(
          'My QR Code',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const LanguagePopup(),
              );
            },
            icon: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('अ', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  Text('A', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last 2 Used UPI IDs
            if (_recentQRCodes.isNotEmpty) ...[
              Text(
                'Last 2 Used UPI IDs',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: _recentQRCodes.take(2).map((qr) => Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _upiControllers[_currentPage].text = qr['upiId'];
                      setState(() {
                        _qrData[_currentPage] = qr['qrData'];
                        _qrGenerated[_currentPage] = true;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            qr['upiId'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap to use',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )).toList(),
              ),
              SizedBox(height: 20),
            ],

            // QR Code Display
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: _qrGenerated[_currentPage]
                    ? Container(
                        width: 250,
                        height: 250,
                        child: PrettyQrView.data(
                          data: _qrData[_currentPage],
                          decoration: const PrettyQrDecoration(
                            shape: PrettyQrSmoothSymbol(
                              color: Colors.black,
                            ),
                            background: Colors.white,
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No QR Code Generated',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
            ),

            SizedBox(height: 20),

            // Generate QR Section
            Text(
              'Generate Your Payment QR',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _upiControllers[_currentPage],
              decoration: InputDecoration(
                hintText: 'Enter UPI ID (e.g., user@paytm)',
                prefixIcon: Icon(Icons.account_balance_wallet, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue[600]!),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : () async {
                  final upiId = _upiControllers[_currentPage].text.trim();
                  if (upiId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter UPI ID')),
                    );
                    return;
                  }
                  if (!_isValidUPI(upiId)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter valid UPI ID (e.g., user@paytm)')),
                    );
                    return;
                  }
                  
                  // Check if user already has 2 QR codes
                  if (_recentQRCodes.length >= 2) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Maximum 2 QR codes allowed per user')),
                    );
                    return;
                  }
                  
                  setState(() {
                    _isLoading = true;
                  });
                  
                  setState(() {
                    _qrData[_currentPage] = _generateUPIQRData(upiId);
                    _qrGenerated[_currentPage] = true;
                  });
                  
                  await _saveQRCode(upiId);
                  
                  setState(() {
                    _isLoading = false;
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('QR Code Generated & Saved!')),
                  );
                },
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Generate QR Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 20),

            // Instructions Dropdown
            GestureDetector(
              onTap: () {
                setState(() {
                  _showInstructions = !_showInstructions;
                });
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'How to use QR Widget',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Icon(
                      _showInstructions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
            if (_showInstructions) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStep(1, 'Enter your UPI ID and generate QR code'),
                    SizedBox(height: 8),
                    _buildStep(2, 'Long press on your home screen'),
                    SizedBox(height: 8),
                    _buildStep(3, 'Tap on \'Widgets\''),
                    SizedBox(height: 8),
                    _buildStep(4, 'Find \'AlertSpeaker\''),
                    SizedBox(height: 8),
                    _buildStep(5, 'Drag the QR widget to your home screen'),
                    SizedBox(height: 8),
                    _buildStep(6, 'Your generated QR code will appear in the widget'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue[600],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (var controller in _upiControllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }
}