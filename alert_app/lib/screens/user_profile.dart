import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/localization_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? userData;
  List<dynamic> userQRs = [];
  bool isLoading = true;
  bool isEditing = false;
  final _usernameController = TextEditingController();
  final _mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final data = await ApiService.getCachedUserData();
    if (data != null) {
      final qrResult = await ApiService.getQRCodes(userId: data['id']);
      setState(() {
        userData = data;
        userQRs = qrResult['qrCodes'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.translate('profile'), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(child: Text('No user data available'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    children: [
                      // Profile Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: screenWidth * 0.1,
                              backgroundColor: Colors.blue,
                              child: Text(
                                (userData!['username'] as String)[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.08,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: screenWidth * 0.03),
                            Text(
                              userData!['username'],
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      
                      // User Details
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  LocalizationService.translate('account_details'),
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (isEditing) {
                                      _saveChanges();
                                    } else {
                                      _startEditing();
                                    }
                                  },
                                  icon: Icon(
                                    isEditing ? Icons.save : Icons.edit,
                                    color: Colors.blue,
                                    size: screenWidth * 0.05,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenWidth * 0.03),
                            _buildDetailRow(LocalizationService.translate('email'), userData!['email'], screenWidth),
                            isEditing 
                                ? _buildEditableRow(LocalizationService.translate('mobile_number'), _mobileController, screenWidth)
                                : _buildDetailRow(LocalizationService.translate('mobile_number'), userData!['mobile'] ?? 'Not provided', screenWidth),
                            isEditing 
                                ? _buildEditableRow(LocalizationService.translate('username'), _usernameController, screenWidth)
                                : _buildDetailRow(LocalizationService.translate('username'), userData!['username'], screenWidth),
                            _buildDetailRow(LocalizationService.translate('status'), LocalizationService.translate('active'), screenWidth),
                          ],
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      
                      // UPI QR Codes
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocalizationService.translate('your_upi_ids'),
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: screenWidth * 0.03),
                            if (userQRs.isEmpty)
                              Text(
                                LocalizationService.translate('no_upi_added'),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: screenWidth * 0.035,
                                ),
                              )
                            else
                              ...userQRs.map((qr) => Container(
                                margin: EdgeInsets.only(bottom: screenWidth * 0.02),
                                padding: EdgeInsets.all(screenWidth * 0.03),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.account_balance_wallet, 
                                         color: Colors.blue, size: screenWidth * 0.05),
                                    SizedBox(width: screenWidth * 0.03),
                                    Expanded(
                                      child: Text(
                                        qr['upiId'],
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  void _startEditing() {
    _usernameController.text = userData!['username'];
    _mobileController.text = userData!['mobile'] ?? '';
    setState(() {
      isEditing = true;
    });
  }

  void _saveChanges() async {
    final newUsername = _usernameController.text.trim();
    final newMobile = _mobileController.text.trim();
    
    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username cannot be empty')),
      );
      return;
    }
    
    if (newMobile.isNotEmpty && newMobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mobile number must be 10 digits')),
      );
      return;
    }
    
    final result = await ApiService.updateProfile(
      userId: userData!['id'],
      username: newUsername,
      mobile: newMobile,
    );
    
    if (result['success'] == true) {
      setState(() {
        userData!['username'] = newUsername;
        userData!['mobile'] = newMobile;
        isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Update failed')),
      );
    }
  }

  Widget _buildDetailRow(String label, String value, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth * 0.25,
            child: Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(String label, TextEditingController controller, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth * 0.25,
            child: Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02,
                  vertical: screenWidth * 0.01,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              keyboardType: label == 'Mobile' ? TextInputType.phone : TextInputType.text,
              maxLength: label == 'Mobile' ? 10 : null,
            ),
          ),
        ],
      ),
    );
  }
}