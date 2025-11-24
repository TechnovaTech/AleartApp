import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../widgets/custom_bottom_navbar.dart';
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

  String _generateUPIQRData(String upiId) {
    return 'upi://pay?pa=$upiId&pn=AlertPe%20Soundbox&cu=INR';
  }

  bool _isValidUPI(String upiId) {
    return RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$').hasMatch(upiId);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final qrBoxSize = screenWidth - 32;

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.blue,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.05,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My QR Code',
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const LanguagePopup(),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenWidth * 0.015,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'अ',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          'A',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: screenWidth * 0.04),
                  SizedBox(
                    height: qrBoxSize + 50,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Container(
                                width: qrBoxSize,
                                height: qrBoxSize,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: _qrGenerated[index]
                                    ? Container(
                                        padding: EdgeInsets.all(20),
                                        child: PrettyQrView.data(
                                          data: _qrData[index],
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
                                            size: qrBoxSize * 0.3,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: qrBoxSize * 0.1),
                                          Text(
                                            'No QR Code Generated',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.045,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                              ),
                              SizedBox(height: screenWidth * 0.02),
                              Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _currentPage == 0 ? Colors.blue : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _currentPage == 1 ? Colors.blue : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generate Your Payment QR',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.03),
                        TextField(
                          controller: _upiControllers[_currentPage],
                          decoration: InputDecoration(
                            hintText: 'UPI ID ${_currentPage + 1}',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenWidth * 0.025,
                            ),
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.03),
                        SizedBox(
                          width: double.infinity,
                          height: screenWidth * 0.11,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: () {
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
                              setState(() {
                                _qrData[_currentPage] = _generateUPIQRData(upiId);
                                _qrGenerated[_currentPage] = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('QR Code Generated Successfully!')),
                              );
                            },
                            child: Text(
                              'Generate QR Code',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.04),
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'How to use QR Widget',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.02),
                              _buildStep(1, 'Enter your UPI ID and generate QR code', screenWidth),
                              SizedBox(height: screenWidth * 0.015),
                              _buildStep(2, 'Long press on your home screen', screenWidth),
                              SizedBox(height: screenWidth * 0.015),
                              _buildStep(3, 'Tap on \'Widgets\'', screenWidth),
                              SizedBox(height: screenWidth * 0.015),
                              _buildStep(4, 'Find \'AlertSpeaker\'', screenWidth),
                              SizedBox(height: screenWidth * 0.015),
                              _buildStep(5, 'Drag the QR widget to your home screen', screenWidth),
                              SizedBox(height: screenWidth * 0.015),
                              _buildStep(6, 'Your generated QR code will appear in the widget', screenWidth),
                            ],
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.03),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildStep(int number, String text, double screenWidth) {
    return Row(
      children: [
        Container(
          width: screenWidth * 0.08,
          height: screenWidth * 0.08,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: Colors.black,
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
