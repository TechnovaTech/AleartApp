import 'dart:convert';

class PaymentParserService {
  static const Map<String, String> appNames = {
    'com.phonepe.app': 'PhonePe',
    'com.google.android.apps.nfc.payment': 'Google Pay',
    'net.one97.paytm': 'Paytm',
    'in.org.npci.upiapp': 'BHIM',
    'in.amazon.mShop.android.shopping': 'Amazon Pay',
  };

  static Map<String, dynamic>? parseNotification(String text, String packageName) {
    // Keywords that indicate incoming payment
    final incomingKeywords = [
      'received',
      'credited',
      'payment received',
      'money added',
      'amount credited',
      'you got',
      'incoming',
    ];

    final lowerText = text.toLowerCase();
    
    // Check if it's an incoming payment
    bool isIncoming = incomingKeywords.any((keyword) => lowerText.contains(keyword));
    if (!isIncoming) return null;

    // Extract amount
    final amountRegex = RegExp(r'₹\s*(\d+(?:,\d+)*(?:\.\d{2})?)');
    final amountMatch = amountRegex.firstMatch(text);
    if (amountMatch == null) return null;

    final amountStr = amountMatch.group(1)?.replaceAll(',', '') ?? '0';
    final amount = double.tryParse(amountStr) ?? 0.0;
    if (amount <= 0) return null;

    // Extract sender info
    String? sender = _extractSender(text);
    String? upiId = _extractUpiId(text);
    String? transactionId = _extractTransactionId(text);

    return {
      'amount': amount,
      'paymentApp': appNames[packageName] ?? 'Unknown',
      'upiId': upiId ?? sender ?? 'Unknown',
      'transactionId': transactionId ?? _generateTransactionId(),
      'notificationText': text,
      'status': 'success',
      'timestamp': DateTime.now().toIso8601String(),
      'date': DateTime.now().toIso8601String().split('T')[0],
      'time': DateTime.now().toIso8601String().split('T')[1].split('.')[0],
      'sender': sender,
    };
  }

  static String? _extractSender(String text) {
    // Patterns to extract sender name
    final patterns = [
      RegExp(r'from\s+([A-Za-z\s]+?)(?:\s+via|\s+on|\s+at|$)', caseSensitive: false),
      RegExp(r'by\s+([A-Za-z\s]+?)(?:\s+via|\s+on|\s+at|$)', caseSensitive: false),
      RegExp(r'([A-Za-z\s]+?)\s+sent', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }
    return null;
  }

  static String? _extractUpiId(String text) {
    // Pattern to extract UPI ID
    final upiRegex = RegExp(r'([a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+)');
    final match = upiRegex.firstMatch(text);
    return match?.group(1);
  }

  static String? _extractTransactionId(String text) {
    // Patterns to extract transaction ID
    final patterns = [
      RegExp(r'UPI Ref No[:\s]+([A-Za-z0-9]+)', caseSensitive: false),
      RegExp(r'Transaction ID[:\s]+([A-Za-z0-9]+)', caseSensitive: false),
      RegExp(r'Txn ID[:\s]+([A-Za-z0-9]+)', caseSensitive: false),
      RegExp(r'ID[:\s]+([A-Za-z0-9]{10,})', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  static String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'TXN$timestamp';
  }
}