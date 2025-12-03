import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/api_service.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  FlutterTts flutterTts = FlutterTts();
  String selectedLanguage = 'en';
  bool isLoading = false;

  final List<Map<String, String>> languages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिंदी'},
    {'code': 'gu', 'name': 'Gujarati', 'nativeName': 'ગુજરાતી'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setVolume(0.8);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _loadCurrentLanguage() async {
    try {
      final userData = await ApiService.getCachedUserData();
      if (userData != null) {
        final response = await ApiService.get('/user/settings?userId=${userData['_id']}');
        if (response['success'] && response['userSettings']['language'] != null) {
          setState(() {
            selectedLanguage = response['userSettings']['language'];
          });
        }
      }
    } catch (e) {
      // Use default language
    }
  }

  Future<void> _testLanguage(String languageCode) async {
    await flutterTts.setLanguage(languageCode);
    
    String testText;
    switch (languageCode) {
      case 'hi':
        testText = 'आपको पेमेंट मिला है';
        break;
      case 'gu':
        testText = 'તમને પેમેન્ટ મળ્યું છે';
        break;
      default:
        testText = 'You have received a payment';
    }
    
    await flutterTts.speak(testText);
  }

  Future<void> _saveLanguage() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userData = await ApiService.getCachedUserData();
      if (userData != null) {
        await ApiService.post('/user/settings', {
          'userId': userData['_id'],
          'language': selectedLanguage,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language preference saved'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save language preference')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Language Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select TTS Language',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Choose the language for voice alerts and notifications',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 24),
            
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  final isSelected = selectedLanguage == language['code'];
                  
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: Radio<String>(
                        value: language['code']!,
                        groupValue: selectedLanguage,
                        onChanged: (value) {
                          setState(() {
                            selectedLanguage = value!;
                          });
                        },
                        activeColor: Colors.blue,
                      ),
                      title: Text(
                        language['name']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        language['nativeName']!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () => _testLanguage(language['code']!),
                        icon: Icon(
                          Icons.volume_up,
                          color: Colors.blue,
                        ),
                        tooltip: 'Test voice',
                      ),
                      onTap: () {
                        setState(() {
                          selectedLanguage = language['code']!;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            
            SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveLanguage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Save Language',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}