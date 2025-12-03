import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ApiService {
  // Use configuration from AppConfig
  static Duration get timeoutDuration => AppConfig.apiTimeout;
  static String get apiUrl => AppConfig.apiUrl;
  
  // Common headers for all requests
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': AppConfig.userAgent,
  };
  
  // Check API connectivity
  static Future<bool> checkConnectivity() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/test'),
        headers: _headers,
      ).timeout(AppConfig.connectivityTimeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  static Future<Map<String, dynamic>> _handleRequest(Future<http.Response> request) async {
    try {
      final response = await request.timeout(timeoutDuration);
      
      // Handle empty response
      if (response.body.isEmpty) {
        return {'success': false, 'error': 'Empty response from server'};
      }
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        // Handle different HTTP status codes
        String errorMessage;
        switch (response.statusCode) {
          case 400:
            errorMessage = data['error'] ?? 'Bad request';
            break;
          case 401:
            errorMessage = 'Unauthorized access';
            break;
          case 403:
            errorMessage = 'Access forbidden';
            break;
          case 404:
            errorMessage = 'Service not found';
            break;
          case 500:
            errorMessage = 'Internal server error';
            break;
          default:
            errorMessage = data['error'] ?? 'Request failed';
        }
        return {'success': false, 'error': errorMessage};
      }
    } on SocketException {
      return {'success': false, 'error': 'No internet connection. Please check your network.'};
    } on HttpException {
      return {'success': false, 'error': 'Network error occurred'};
    } on FormatException {
      return {'success': false, 'error': 'Invalid response format from server'};
    } on TimeoutException {
      return {'success': false, 'error': 'Request timeout. Please try again.'};
    } catch (e) {
      return {'success': false, 'error': 'Service temporarily unavailable. Please try again later.'};
    }
  }
  
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String mobile,
  }) async {
    final request = http.post(
      Uri.parse('$apiUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'mobile': mobile,
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
      Uri.parse('$apiUrl/auth/login'),
      headers: _headers,
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
    await prefs.setString('user_mobile', user['mobile'] ?? '');
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
      'mobile': prefs.getString('user_mobile') ?? '',
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
      Uri.parse('$apiUrl/qr'),
      headers: _headers,
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
      Uri.parse('$apiUrl/qr?userId=$userId'),
      headers: _headers,
    );
    
    return await _handleRequest(request);
  }
  
  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String username,
    required String mobile,
  }) async {
    final request = http.patch(
      Uri.parse('$apiUrl/users/$userId'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'mobile': mobile,
      }),
    );
    
    final result = await _handleRequest(request);
    
    // Update cached data if successful
    if (result['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_username', username);
      await prefs.setString('user_mobile', mobile);
    }
    
    return result;
  }
  
  static Future<Map<String, dynamic>> getPlans() async {
    final request = http.get(
      Uri.parse('$apiUrl/plans'),
      headers: _headers,
    );
    
    return await _handleRequest(request);
  }
  
  static Future<Map<String, dynamic>> sendOTP({
    required String email,
  }) async {
    final request = http.post(
      Uri.parse('$apiUrl/auth/send-otp'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
      }),
    );
    
    return await _handleRequest(request);
  }
  
  static Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String otp,
  }) async {
    final request = http.post(
      Uri.parse('$apiUrl/auth/verify-otp'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );
    
    return await _handleRequest(request);
  }
  
  static Future<Map<String, dynamic>> savePayment({
    String? userId,
    required double amount,
    required String paymentApp,
    required String upiId,
    required String transactionId,
    required String notificationText,
  }) async {
    // Get userId from cache if not provided
    if (userId == null) {
      final userData = await getCachedUserData();
      userId = userData?['id'] ?? '';
    }
    final request = http.post(
      Uri.parse('$apiUrl/payments'),
      headers: _headers,
      body: jsonEncode({
        'userId': userId,
        'amount': amount.toString(),
        'paymentApp': paymentApp,
        'upiId': upiId,
        'transactionId': transactionId,
        'notificationText': notificationText,
      }),
    );
    
    return await _handleRequest(request);
  }
  
  static Future<Map<String, dynamic>> getPayments({
    required String userId,
    String date = 'all',
  }) async {
    final request = http.get(
      Uri.parse('$apiUrl/payments?userId=$userId&date=$date'),
      headers: _headers,
    );
    
    return await _handleRequest(request);
  }
  
  // Generic GET method for new screens
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final request = http.get(
      Uri.parse('$apiUrl$endpoint'),
      headers: _headers,
    );
    
    return await _handleRequest(request);
  }
  
  // Generic POST method for new screens
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final request = http.post(
      Uri.parse('$apiUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );
    
    return await _handleRequest(request);
  }
}