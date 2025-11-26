// App Configuration
class AppConfig {
  // Environment settings
  static const bool isProduction = true;
  static const bool enableLogging = !isProduction;
  
  // API Configuration
  static const String productionApiUrl = 'https://technovatechnologies.online/api';
  static const String developmentApiUrl = 'http://localhost:3000/api';
  
  // App Information
  static const String appName = 'AlertPe';
  static const String appVersion = '1.0.0';
  static const String userAgent = 'AlertApp/1.0.0';
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 15);
  static const Duration connectivityTimeout = Duration(seconds: 5);
  
  // Get current API URL based on environment
  static String get apiUrl => isProduction ? productionApiUrl : developmentApiUrl;
  
  // Feature flags
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = isProduction;
}