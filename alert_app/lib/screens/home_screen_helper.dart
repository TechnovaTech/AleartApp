  String _calculateTotalAmount() {
    final payments = _generateDynamicPayments();
    int total = 0;
    
    for (var payment in payments) {
      String amountStr = payment['amount'].toString().replaceAll('₹', '').replaceAll(',', '');
      total += int.tryParse(amountStr) ?? 0;
    }
    
    return total.toString();
  }