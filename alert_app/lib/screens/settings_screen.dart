import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../widgets/user_profile_widget.dart';
import '../widgets/language_button.dart';
import 'my_qr.dart';
import 'login.dart';
import '../services/api_service.dart';
import '../services/localization_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    LocalizationService.loadLanguage().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          LocalizationService.translate('settings'),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.045,
          ),
        ),
        actions: const [
          LanguageButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const UserProfileWidget(),
            SizedBox(height: screenWidth * 0.02),
            _buildSection(LocalizationService.translate('subscription'), screenWidth),
            _buildSubscriptionItem(screenWidth),
            SizedBox(height: screenWidth * 0.02),
            _buildSection(LocalizationService.translate('voice_settings'), screenWidth),
            _buildSettingItem(
              Icons.music_note,
              LocalizationService.translate('notification_sound'),
              '',
              screenWidth,
            ),
            SizedBox(height: screenWidth * 0.02),
            _buildSettingItem(
              Icons.volume_up,
              LocalizationService.translate('test_notification'),
              '',
              screenWidth,
            ),
            SizedBox(height: screenWidth * 0.02),
            _buildSection(LocalizationService.translate('general'), screenWidth),
            _buildSettingItem(
              Icons.notifications,
              LocalizationService.translate('permissions'),
              '',
              screenWidth,
            ),
            SizedBox(height: screenWidth * 0.02),
            _buildSettingItem(
              Icons.headset_mic,
              LocalizationService.translate('contact_support'),
              '',
              screenWidth,
            ),
            SizedBox(height: screenWidth * 0.02),
            _buildSettingItem(
              Icons.security,
              LocalizationService.translate('privacy_policy'),
              '',
              screenWidth,
            ),
            SizedBox(height: screenWidth * 0.02),
            _buildSettingItem(
              Icons.description,
              LocalizationService.translate('terms_of_service'),
              '',
              screenWidth,
            ),
            SizedBox(height: screenWidth * 0.04),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(LocalizationService.translate('logout')),
                    content: Text(LocalizationService.translate('logout_confirm')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(LocalizationService.translate('cancel')),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await ApiService.logout();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        child: Text(LocalizationService.translate('logout'), style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenWidth * 0.02,
                ),
                padding: EdgeInsets.all(screenWidth * 0.025),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white, size: screenWidth * 0.045),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      LocalizationService.translate('logout'),
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.08),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyQRScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildSection(String title, double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.03,
      ),
      color: Colors.grey[200],
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle,
    double screenWidth,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.02,
      ),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: screenWidth * 0.06),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: screenWidth * 0.04, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSubscriptionItem(double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.02,
      ),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.card_giftcard, color: Colors.blue, size: screenWidth * 0.06),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Text(
              LocalizationService.translate('alertpe_soundbox'),
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenWidth * 0.01,
            ),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              LocalizationService.translate('soon'),
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
