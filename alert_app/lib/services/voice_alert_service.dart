import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VoiceAlertService {
  static FlutterTts? _flutterTts;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterTts = FlutterTts();
    
    // Configure TTS settings
    await _flutterTts!.setLanguage('en-IN'); // Indian English
    await _flutterTts!.setSpeechRate(0.8);
    await _flutterTts!.setVolume(1.0);
    await _flutterTts!.setPitch(1.0);

    _isInitialized = true;
  }

  static Future<void> announcePayment(Map<String, dynamic> paymentData) async {
    await initialize();
    
    final prefs = await SharedPreferences.getInstance();
    final isVoiceEnabled = prefs.getBool('voice_alerts_enabled') ?? true;
    
    if (!isVoiceEnabled) return;

    final amount = paymentData['amount']?.toString() ?? '0';
    final sender = paymentData['sender'] ?? paymentData['upiId'] ?? 'Unknown';
    final app = paymentData['paymentApp'] ?? 'UPI';

    String message;
    if (sender != 'Unknown') {
      message = "You have received rupees $amount from $sender via $app";
    } else {
      message = "You have received rupees $amount via $app";
    }

    await _speak(message);
  }

  static Future<void> announceCustomMessage(String message) async {
    await initialize();
    await _speak(message);
  }

  static Future<void> _speak(String message) async {
    try {
      print('Speaking: $message');
      await _flutterTts!.speak(message);
    } catch (e) {
      print('Error in TTS: $e');
    }
  }

  static Future<void> setLanguage(String languageCode) async {
    await initialize();
    
    final languageMap = {
      'en': 'en-IN',
      'hi': 'hi-IN',
      'te': 'te-IN',
      'ta': 'ta-IN',
      'bn': 'bn-IN',
      'gu': 'gu-IN',
      'kn': 'kn-IN',
      'ml': 'ml-IN',
      'mr': 'mr-IN',
      'pa': 'pa-IN',
    };

    final ttsLanguage = languageMap[languageCode] ?? 'en-IN';
    await _flutterTts!.setLanguage(ttsLanguage);
    
    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_language', languageCode);
  }

  static Future<void> setVoiceAlertsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voice_alerts_enabled', enabled);
  }

  static Future<bool> isVoiceAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('voice_alerts_enabled') ?? true;
  }

  static Future<void> testVoiceAlert() async {
    await announceCustomMessage("Voice alerts are working correctly. You will hear payment notifications like this.");
  }

  static void dispose() {
    _flutterTts?.stop();
    _isInitialized = false;
  }
}