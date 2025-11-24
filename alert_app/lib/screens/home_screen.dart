import 'package:flutter/material.dart';
import 'language_popup.dart';
import 'filter_popup.dart';
import 'reports_screen.dart';
import 'my_qr.dart';
import 'settings_screen.dart';
import '../widgets/activate_alerts_bottom_sheet.dart';
import '../widgets/custom_bottom_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _checkAndShowPermissions();
  }

  void _checkAndShowPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    // Reset for testing - remove this line in production
    await prefs.setBool('permissions_shown', false);
    
    final hasShownPermissions = prefs.getBool('permissions_shown') ?? false;
    
    if (!hasShownPermissions) {
      // Show permission popup after a short delay
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
            // Mark as shown so it doesn't appear again
            await prefs.setBool('permissions_shown', true);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
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
      return 'Today\'s Collection';
    } else if (index == 1) {
      return 'Yesterday\'s Collection';
    } else {
      return 'November Collection';
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
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AlertPe Soundbox',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.045,
              ),
            ),
            Text(
              'Online',
              style: TextStyle(
                color: Colors.yellow[600],
                fontSize: screenWidth * 0.03,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const LanguagePopup(),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.blue[300]!, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.035,
                  vertical: screenWidth * 0.025,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'अ',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      'A',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blue,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.03,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TabButton('Today', 0, screenWidth),
                _TabButton('Yesterday', 1, screenWidth),
                _TabButton('This Month', 2, screenWidth),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedTab = index;
                });
              },
              children: [
                _buildPage(0, screenWidth),
                _buildPage(1, screenWidth),
                _buildPage(2, screenWidth),
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

  Widget _buildPage(int index, double screenWidth) {
    DateTime? filterStart = tabFilters[index]?['start'];
    DateTime? filterEnd = tabFilters[index]?['end'];
    
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(screenWidth * 0.04),
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getDate(index),
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getTitle(index),
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹0',
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.03),
                GestureDetector(
                  onTap: () {
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
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'OPEN REPORT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by amount',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                GestureDetector(
                  onTap: _openFilter,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenWidth * 0.03,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list),
                        SizedBox(width: screenWidth * 0.01),
                        const Text('Filter'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (filterStart != null && filterEnd != null)
            Container(
              margin: EdgeInsets.all(screenWidth * 0.04),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03,
                vertical: screenWidth * 0.02,
              ),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter: ${filterStart.day} Nov ${filterStart.year} - ${filterEnd.day} Nov ${filterEnd.year}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: _clearFilter,
                    child: Icon(Icons.close, size: screenWidth * 0.045),
                  ),
                ],
              ),
            ),
          SizedBox(height: screenWidth * 0.1),
          Text(
            'No payment history',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: screenWidth * 0.1),
        ],
      ),
    );
  }

  Widget _TabButton(String label, int index, double screenWidth) {
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_selectedTab == index)
            Container(
              margin: EdgeInsets.only(top: screenWidth * 0.01),
              height: 3,
              width: screenWidth * 0.1,
              color: Colors.yellow[600],
            ),
        ],
      ),
    );
  }
}
