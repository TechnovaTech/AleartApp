import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const Duration timeoutDuration = Duration(seconds: 10);
  
  static Future<Map<String, dynamic>> _handleRequest(Future<http.Response> request) async {
    try {
      final response = await request.timeout(timeoutDuration);
      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Request failed'
        };
      }
    } on SocketException {
      return {'success': false, 'error': 'Server not running. Start Next.js server first.'};
    } on HttpException {
      return {'success': false, 'error': 'Server error'};
    } on FormatException {
      return {'success': false, 'error': 'Invalid response format'};
    } catch (e) {
      return {'success': false, 'error': 'Server not available. Run: npm run dev in alert_admin folder'};
    }
  }
  
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final request = http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    
    final result = await _handleRequest(request);
    
    // Cache user data on successful registration
    if (result['success'] == true && result['user'] != null) {
      await _cacheUserData(result['user']);
    }
    
    return result;
  }
  
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final request = http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    final result = await _handleRequest(request);
    
    // Cache user data on successful login
    if (result['success'] == true && result['user'] != null) {
      await _cacheUserData(result['user']);
    }
    
    return result;
  }
  
  static Future<void> _cacheUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user['id'] ?? '');
    await prefs.setString('user_email', user['email'] ?? '');
    await prefs.setString('user_name', user['name'] ?? '');
    await prefs.setString('user_username', user['username'] ?? '');
    await prefs.setBool('is_logged_in', true);
    await prefs.setInt('last_login', DateTime.now().millisecondsSinceEpoch);
  }
  
  static Future<Map<String, dynamic>?> getCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    
    if (!isLoggedIn) return null;
    
    return {
      'id': prefs.getString('user_id') ?? '',
      'email': prefs.getString('user_email') ?? '',
      'name': prefs.getString('user_name') ?? '',
      'username': prefs.getString('user_username') ?? '',
      'last_login': prefs.getInt('last_login') ?? 0,
    };
  }
  
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }
  
  static Future<Map<String, dynamic>> saveQRCode({
    required String upiId,
    required String userId,
  }) async {
    final request = http.post(
      Uri.parse('$baseUrl/qr'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'upiId': upiId,
        'userId': userId,
      }),
    );
    
    return await _handleRequest(request);
  }
  
  static Future<Map<String, dynamic>> getQRCodes({
    required String userId,
  }) async {
    final request = http.get(
      Uri.parse('$baseUrl/qr?userId=$userId'),
      headers: {'Content-Type': 'application/json'},
    );
    
    return await _handleRequest(request);
  }
}