class PIIMasking {
  static final RegExp _otpRegExp = RegExp(r'\b\d{4,8}\b');
  static final RegExp _cardRegExp = RegExp(r'\b(?:\d[ -]*?){13,16}\b');
  static final RegExp _upiPinRegExp = RegExp(r'(?i)upi pin\s*[:\-]?\s*(\d{4,6})');
  static final RegExp _amountRegExp = RegExp(r'(?i)(rs\.?|inr|₹)\s*(\d+(?:,\d+)*(?:\.\d+)?)');

  static String maskData(String input) {
    if (input.isEmpty) return input;
    String masked = input;
    
    // Mask standard 4-8 digit numbers (OTPs)
    masked = masked.replaceAllMapped(_otpRegExp, (match) {
      final value = match.group(0)!;
      return '*' * value.length;
    });

    // Mask Credit/Debit Card numbers
    masked = masked.replaceAllMapped(_cardRegExp, (match) {
      final value = match.group(0)!;
      return '*' * value.length;
    });

    // Mask specific UPI PIN context
    masked = masked.replaceAllMapped(_upiPinRegExp, (match) {
      final pin = match.group(1)!;
      return match.group(0)!.replaceFirst(pin, '*' * pin.length);
    });

    // We do NOT mask amounts, as they are crucial for parsing intent (e.g., Collect Requests)
    return masked;
  }
}
