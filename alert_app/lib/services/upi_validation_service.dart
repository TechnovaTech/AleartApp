class UpiValidationService {
  static bool isValidUpiId(String upiId) {
    if (upiId.isEmpty) return false;
    
    // UPI ID format: username@bankcode
    final RegExp upiRegex = RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');
    return upiRegex.hasMatch(upiId);
  }

  static String? validateUpiId(String upiId) {
    if (upiId.isEmpty) {
      return 'UPI ID is required';
    }
    
    if (!upiId.contains('@')) {
      return 'UPI ID must contain @ symbol';
    }
    
    final parts = upiId.split('@');
    if (parts.length != 2) {
      return 'Invalid UPI ID format';
    }
    
    final username = parts[0];
    final bankCode = parts[1];
    
    if (username.length < 2 || username.length > 256) {
      return 'Username must be between 2-256 characters';
    }
    
    if (bankCode.length < 2 || bankCode.length > 64) {
      return 'Bank code must be between 2-64 characters';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9.\-_]+$').hasMatch(username)) {
      return 'Username can only contain letters, numbers, dots, hyphens, and underscores';
    }
    
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(bankCode)) {
      return 'Bank code can only contain letters';
    }
    
    return null; // Valid UPI ID
  }

  static String formatUpiId(String upiId) {
    return upiId.toLowerCase().trim();
  }

  static List<String> getCommonBankCodes() {
    return [
      'paytm',
      'phonepe',
      'googlepay',
      'amazonpay',
      'bhim',
      'ybl',
      'ibl',
      'axl',
      'okhdfcbank',
      'okicici',
      'okaxis',
      'oksbi',
      'okhdfc',
    ];
  }

  static String? extractUpiIdFromText(String text) {
    final RegExp upiRegex = RegExp(r'([a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64})');
    final match = upiRegex.firstMatch(text);
    return match?.group(1);
  }
}