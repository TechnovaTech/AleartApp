import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  final int tabIndex;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  const ReportsScreen({
    super.key,
    required this.tabIndex,
    this.filterStartDate,
    this.filterEndDate,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late DateTime startDate;
  late DateTime endDate;
  List<Map<String, dynamic>> _payments = [];
  bool _loading = true;
  String _selectedApp = 'All';
  double _minAmount = 0;
  double _maxAmount = 10000;

  @override
  void initState() {
    super.initState();
    if (widget.filterStartDate != null && widget.filterEndDate != null) {
      startDate = widget.filterStartDate!;
      endDate = widget.filterEndDate!;
    } else {
      if (widget.tabIndex == 0) {
        startDate = DateTime.now();
        endDate = DateTime.now();
      } else if (widget.tabIndex == 1) {
        startDate = DateTime.now().subtract(const Duration(days: 1));
        endDate = DateTime.now().subtract(const Duration(days: 1));
      } else {
        startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
        endDate = DateTime.now();
      }
    }
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _loading = true);
    final userData = await ApiService.getCachedUserData();
    if (userData != null) {
      final result = await ApiService.getPayments(userId: userData['id'], date: 'all');
      if (result['success'] == true && result['payments'] != null) {
        setState(() {
          _payments = (result['payments'] as List).map((p) => Map<String, dynamic>.from(p)).toList();
          _loading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get filteredPayments {
    return _payments.where((payment) {
      final paymentDate = DateTime.tryParse(payment['timestamp'] ?? '') ?? DateTime.now();
      final amount = double.tryParse(payment['amount'].toString()) ?? 0;
      
      bool dateMatch = paymentDate.isAfter(startDate.subtract(Duration(days: 1))) && 
                      paymentDate.isBefore(endDate.add(Duration(days: 1)));
      bool appMatch = _selectedApp == 'All' || payment['paymentApp'] == _selectedApp;
      bool amountMatch = amount >= _minAmount && amount <= _maxAmount;
      
      return dateMatch && appMatch && amountMatch;
    }).toList();
  }

  double get totalAmount {
    return filteredPayments.fold(0.0, (sum, payment) => 
      sum + (double.tryParse(payment['amount'].toString()) ?? 0));
  }

  Map<String, int> get appBreakdown {
    Map<String, int> breakdown = {};
    for (var payment in filteredPayments) {
      String app = payment['paymentApp'] ?? 'Unknown';
      breakdown[app] = (breakdown[app] ?? 0) + 1;
    }
    return breakdown;
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
      });
      _loadPayments();
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
      });
      _loadPayments();
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Reports',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: MediaQuery.of(context).size.width * 0.045,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Period',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _selectStartDate,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Start Date',
                                            style: TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatDate(startDate),
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const Icon(Icons.filter_list, color: Colors.blue, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: _selectEndDate,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'End Date',
                                            style: TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatDate(endDate),
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const Icon(Icons.filter_list, color: Colors.blue, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Summary',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Transactions',
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${filteredPayments.length}',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Collection',
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '₹${totalAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredPayments.length,
                      itemBuilder: (context, index) {
                        final payment = filteredPayments[index];
                        final amount = double.tryParse(payment['amount'].toString()) ?? 0;
                        final timestamp = DateTime.tryParse(payment['timestamp'] ?? '') ?? DateTime.now();
                        final localTime = timestamp.add(const Duration(hours: 5, minutes: 30));
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹${amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')} ${localTime.hour >= 12 ? 'PM' : 'AM'}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'App: ${payment['paymentApp'] ?? 'Unknown'}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'UPI: ${payment['upiId'] ?? 'Unknown'}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: ${payment['transactionId'] ?? 'Unknown'}',
                                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Downloading PDF...')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download, size: 18),
                          SizedBox(width: 8),
                          Text('Download PDF'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sharing to WhatsApp...')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'WhatsApp',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}