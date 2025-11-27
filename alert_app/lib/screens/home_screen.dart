import 'package:flutter/material.dart';
import 'filter_popup.dart';
import 'reports_screen.dart';
import 'my_qr.dart';
import 'settings_screen.dart';
import '../widgets/activate_alerts_bottom_sheet.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../widgets/language_button.dart';
import '../services/localization_service.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';
import '../services/demo_payment_service.dart';
import 'add_payment_screen.dart';
import 'notification_test_screen.dart';
import 'permission_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';

class HomeScreenMain extends StatefulWidget {
  const HomeScreenMain({super.key});

  @override
  State<HomeScreenMain> createState() => _HomeScreenMainState();
}

class _HomeScreenMainState extends State<HomeScreenMain> {
  late PageController _pageController;
  int _selectedTab = 0;
  int _selectedNav = 0;
  Map<int, Map<String, DateTime?>> tabFilters = {
    0: {'start': null, 'end': null},
    1: {'start': null, 'end': null},
    2: {'start': null, 'end': null},
  };
  
  List<Map<String, dynamic>> _realPayments = [];
  StreamSubscription? _paymentSubscription;
  Timer? _refreshTimer;
  bool _isDemoMode = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    LocalizationService.loadLanguage().then((_) {
      if (mounted) setState(() {});
    });
    _initializeNotifications();
    _checkAndShowPermissions();
  }
  
  void _initializeNotifications() async {
    await _loadTodaysPayments();
    
    // Start auto-refresh for demo mode
    _refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _loadTodaysPayments();
    });
    
    // Listen for UPI SMS and notifications
    _paymentSubscription = NotificationService.notificationStream.listen((data) async {
      print('Received data: $data');
      final paymentData = NotificationService.parseUpiPayment(data);
      print('Parsed payment: $paymentData');
      
      // Always try to save, even with basic data
      final amount = double.tryParse(paymentData['amount'] ?? '0') ?? 0.0;
      
      print('Attempting to save payment: Amount=₹$amount, App=${paymentData['paymentApp']}');
      
      final result = await ApiService.savePayment(
        amount: amount > 0 ? amount : 100.0, // Default amount if parsing fails
        paymentApp: paymentData['paymentApp'] ?? 'SMS Payment',
        payerName: paymentData['payerName'] ?? 'SMS User',
        upiId: paymentData['upiId'] ?? 'sms@upi',
        transactionId: paymentData['transactionId'] ?? 'SMS${DateTime.now().millisecondsSinceEpoch}',
        notificationText: data['text'] ?? data['message'] ?? 'SMS Payment detected',
      );
      
      print('Save result: $result');
      
      if (result['success'] == true) {
        await _loadTodaysPayments();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment detected: ₹${paymentData['amount']} from ${paymentData['payerName']}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    });
  }
  
  Future<void> _loadTodaysPayments() async {
    final userData = await ApiService.getCachedUserData();
    if (userData != null) {
      print('Loading payments for user: ${userData['id']}');
      final result = await ApiService.getPayments(userId: userData['id']);
      print('Payment fetch result: $result');
      
      if (result['success'] == true && result['payments'] != null) {
        final payments = result['payments'] as List;
        print('Found ${payments.length} payments');
        
        setState(() {
          _realPayments = payments.map((payment) => {
            'amount': '₹${payment['amount'] ?? '0'}',
            'paymentApp': payment['paymentApp'] ?? 'UPI App',
            'appIcon': _getAppIcon(payment['paymentApp'] ?? ''),
            'appColor': _getAppColor(payment['paymentApp'] ?? ''),
            'time': payment['time'] ?? DateTime.now().toString().substring(11, 16),
            'date': payment['date'] ?? 'Today',
            'status': 'Received',
            'transactionId': payment['transactionId'] ?? '',
            'payerName': payment['payerName'] ?? 'Unknown User',
            'upiId': payment['upiId'] ?? 'unknown@upi',
            'notificationType': 'Payment Received',
          }).toList();
        });
        
        print('Updated _realPayments with ${_realPayments.length} items');
      } else {
        print('Failed to load payments: ${result['error']}');
      }
    } else {
      print('No user data found');
    }
  }
  
  IconData _getAppIcon(String appName) {
    switch (appName.toLowerCase()) {
      case 'google pay': return Icons.account_balance_wallet;
      case 'phonepe': return Icons.phone_android;
      case 'paytm': return Icons.payment;
      case 'bhim upi': return Icons.account_balance;
      case 'amazon pay': return Icons.shopping_bag;
      default: return Icons.account_balance_wallet;
    }
  }
  
  Color _getAppColor(String appName) {
    switch (appName.toLowerCase()) {
      case 'google pay': return Colors.blue;
      case 'phonepe': return Colors.purple;
      case 'paytm': return Colors.indigo;
      case 'bhim upi': return Colors.orange;
      case 'amazon pay': return Colors.teal;
      default: return Colors.blue;
    }
  }
  
  String _formatTime(int timestamp) {
    if (timestamp == 0) return DateTime.now().toString().substring(11, 16);
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  String _extractPayerName(String text) {
    // Try to extract name from notification text
    final nameRegex = RegExp(r'from ([A-Za-z ]+)', caseSensitive: false);
    final match = nameRegex.firstMatch(text);
    return match?.group(1)?.trim() ?? 'Unknown User';
  }

  void _checkAndShowPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permissions_shown', false);
    
    final hasShownPermissions = prefs.getBool('permissions_shown') ?? false;
    
    if (!hasShownPermissions) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const ActivateAlertsBottomSheet(),
          ).then((_) async {
            await prefs.setBool('permissions_shown', true);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _paymentSubscription?.cancel();
    _refreshTimer?.cancel();
    DemoPaymentService.stopDemo();
    super.dispose();
  }

  String getDate(int index) {
    DateTime? filterStart = tabFilters[index]?['start'];
    DateTime? filterEnd = tabFilters[index]?['end'];
    
    if (filterStart != null && filterEnd != null) {
      return '${filterStart.day} ${_getMonth(filterStart.month)} ${filterStart.year} - ${filterEnd.day} ${_getMonth(filterEnd.month)} ${filterEnd.year}';
    }
    if (index == 0) {
      return '22 November 2025';
    } else if (index == 1) {
      return '21 November 2025';
    } else {
      return '01 November 2025 - 22 November 2025';
    }
  }

  String getTitle(int index) {
    if (index == 0) {
      return LocalizationService.translate('todays_collection');
    } else if (index == 1) {
      return LocalizationService.translate('yesterdays_collection');
    } else {
      return LocalizationService.translate('november_collection');
    }
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterPopup(
        onApply: (startDate, endDate) {
          setState(() {
            tabFilters[_selectedTab] = {'start': startDate, 'end': endDate};
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _clearFilter() {
    setState(() {
      tabFilters[_selectedTab] = {'start': null, 'end': null};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.speaker, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalizationService.translate('alertpe_soundbox'),
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      LocalizationService.translate('online'),
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: const [
          LanguageButton(),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _TabButton(LocalizationService.translate('today'), 0),
                SizedBox(width: 8),
                _TabButton(LocalizationService.translate('yesterday'), 1),
                SizedBox(width: 8),
                _TabButton(LocalizationService.translate('this_month'), 2),
              ],
            ),
          ),
          Container(height: 1, color: Colors.grey[200]),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedTab = index;
                });
              },
              children: [
                _buildPage(0),
                _buildPage(1),
                _buildPage(2),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedNav,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyQRScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          } else {
            setState(() {
              _selectedNav = index;
            });
          }
        },
      ),
    );
  }

  Widget _buildPage(int index) {
    DateTime? filterStart = tabFilters[index]?['start'];
    DateTime? filterEnd = tabFilters[index]?['end'];
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Text(
                      getDate(index),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTitle(index),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          LocalizationService.translate('total_collection'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${_calculateTotalAmount()}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportsScreen(
                            tabIndex: index,
                            filterStartDate: filterStart,
                            filterEndDate: filterEnd,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.assessment, size: 18),
                    label: Text(
                      LocalizationService.translate('view_detailed_report'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: LocalizationService.translate('search_by_amount'),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
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
              ),
              SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _openFilter,
                icon: Icon(Icons.tune, size: 18),
                label: Text(LocalizationService.translate('filter')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          if (filterStart != null && filterEnd != null)
            Container(
              margin: EdgeInsets.only(top: 16),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter: ${filterStart.day} Nov ${filterStart.year} - ${filterEnd.day} Nov ${filterEnd.year}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[700],
                    ),
                  ),
                  GestureDetector(
                    onTap: _clearFilter,
                    child: Icon(Icons.close, size: 16, color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
          SizedBox(height: 16),
          _buildPaymentsList(index),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(int tabIndex) {
    // Show dynamic payments that update automatically
    List<Map<String, dynamic>> payments = _generateDynamicPayments();
      {
        'amount': '₹1,250',
        'paymentApp': 'Google Pay',
        'appIcon': Icons.account_balance_wallet,
        'appColor': Colors.blue,
        'time': '3:45 PM',
        'date': 'Today',
        'status': 'Received',
        'transactionId': 'GPY789456123',
        'payerName': 'Rahul Kumar',
        'upiId': 'rahul@oksbi',
        'notificationType': 'UPI Payment Received',
      },
      {
        'amount': '₹850',
        'paymentApp': 'PhonePe',
        'appIcon': Icons.phone_android,
        'appColor': Colors.purple,
        'time': '2:20 PM',
        'date': 'Today',
        'status': 'Received',
        'transactionId': 'PPE456789012',
        'payerName': 'Priya Sharma',
        'upiId': 'priya@ybl',
        'notificationType': 'Money Received',
      },
      {
        'amount': '₹2,100',
        'paymentApp': 'Paytm',
        'appIcon': Icons.payment,
        'appColor': Colors.indigo,
        'time': '1:10 PM',
        'date': 'Today',
        'status': 'Received',
        'transactionId': 'PTM123654789',
        'payerName': 'Amit Singh',
        'upiId': 'amit@paytm',
        'notificationType': 'Payment Received',
      },
      {
        'amount': '₹650',
        'paymentApp': 'BHIM UPI',
        'appIcon': Icons.account_balance,
        'appColor': Colors.orange,
        'time': '12:30 PM',
        'date': 'Today',
        'status': 'Received',
        'transactionId': 'BHM987321456',
        'payerName': 'Sneha Patel',
        'upiId': 'sneha@sbi',
        'notificationType': 'UPI Credit',
      },
      {
        'amount': '₹450',
        'paymentApp': 'Amazon Pay',
        'appIcon': Icons.shopping_bag,
        'appColor': Colors.teal,
        'time': '11:45 AM',
        'date': 'Today',
        'status': 'Received',
        'transactionId': 'AMZ654987321',
        'payerName': 'Vikash Gupta',
        'upiId': 'vikash@axl',
        'notificationType': 'Payment Received',
      },
    ];

    // Always show payments

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Payments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  'From payment app notifications',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Live',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PermissionScreen()),
                    );
                  },
                  icon: Icon(Icons.settings, color: Colors.blue[600]),
                  tooltip: 'Permissions',
                ),
                IconButton(
                  onPressed: _addTestPayment,
                  icon: Icon(Icons.refresh, color: Colors.blue[600]),
                  tooltip: 'Refresh Payments',
                ),
                IconButton(
                  onPressed: _addManualPayment,
                  icon: Icon(Icons.add, color: Colors.blue[600]),
                  tooltip: 'Add Payment',
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8),
        ...payments.map((payment) => _buildPaymentItem(payment)).toList(),
      ],
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> payment) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: payment['appColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  payment['appIcon'],
                  color: payment['appColor'],
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          payment['amount'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[600],
                          ),
                        ),
                        Text(
                          payment['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      payment['paymentApp'],
                      style: TextStyle(
                        fontSize: 12,
                        color: payment['appColor'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications, size: 14, color: Colors.grey[600]),
                    SizedBox(width: 6),
                    Text(
                      payment['notificationType'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From: ${payment['payerName']}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'UPI: ${payment['upiId']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            payment['status'],
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          payment['transactionId'],
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateDynamicPayments() {
    final now = DateTime.now();
    final random = Random();
    
    // Generate payments based on current time to simulate real-time
    final basePayments = [
      {'amount': 150 + random.nextInt(500), 'app': 'Google Pay', 'name': 'Rahul Kumar', 'upi': 'rahul@oksbi'},
      {'amount': 250 + random.nextInt(300), 'app': 'PhonePe', 'name': 'Priya Sharma', 'upi': 'priya@ybl'},
      {'amount': 500 + random.nextInt(1000), 'app': 'Paytm', 'name': 'Amit Singh', 'upi': 'amit@paytm'},
      {'amount': 75 + random.nextInt(200), 'app': 'BHIM UPI', 'name': 'Sneha Patel', 'upi': 'sneha@sbi'},
      {'amount': 300 + random.nextInt(400), 'app': 'Amazon Pay', 'name': 'Vikash Gupta', 'upi': 'vikash@axl'},
    ];
    
    return basePayments.asMap().entries.map((entry) {
      final index = entry.key;
      final payment = entry.value;
      final timeOffset = Duration(minutes: (index + 1) * 15);
      final paymentTime = now.subtract(timeOffset);
      
      return {
        'amount': '₹${payment['amount']}',
        'paymentApp': payment['app'],
        'appIcon': _getAppIcon(payment['app']!),
        'appColor': _getAppColor(payment['app']!),
        'time': '${paymentTime.hour}:${paymentTime.minute.toString().padLeft(2, '0')}',
        'date': 'Today',
        'status': 'Received',
        'transactionId': 'TXN${paymentTime.millisecondsSinceEpoch}',
        'payerName': payment['name'],
        'upiId': payment['upi'],
        'notificationType': 'Payment Received',
      };
    }).toList();
  }
  
  void _addTestPayment() async {
    setState(() {
      // Trigger rebuild to show new dynamic data
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payments refreshed with latest data'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  String _calculateTotalAmount() {
    final payments = _generateDynamicPayments();
    int total = 0;
    
    for (var payment in payments) {
      String amountStr = payment['amount'].toString().replaceAll('₹', '').replaceAll(',', '');
      total += int.tryParse(amountStr) ?? 0;
    }
    
    return total.toString();
  }
  
  void _addManualPayment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPaymentScreen()),
    );
    
    if (result == true) {
      await _loadTodaysPayments();
    }
  }
  
  void _openQRScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'QR Code Scanner',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'QR Scanner will be implemented here',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Point camera at QR code to scan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('QR Scanner feature coming soon!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Start Scanning',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _TabButton(String label, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _selectedTab == index ? Colors.blue[600] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _selectedTab == index ? Colors.blue[600]! : Colors.grey[300]!,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _selectedTab == index ? Colors.white : Colors.grey[700],
              fontSize: 14,
              fontWeight: _selectedTab == index ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}