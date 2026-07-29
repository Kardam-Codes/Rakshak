class PIIMasking {
  static final RegExp _otpRegExp = RegExp(r'\b\d{4,8}\b');
  static final RegExp _cardRegExp = RegExp(r'\b(?:\d[ -]*?){13,16}\b');
  static final RegExp _upiPinRegExp = RegExp(r'upi pin\s*[:\-]?\s*(\d{4,6})', caseSensitive: false);
  static final RegExp _amountRegExp = RegExp(r'(rs\.?|inr|₹)\s*(\d+(?:,\d+)*(?:\.\d+)?)', caseSensitive: false);
  static final RegExp _upiIdRegExp = RegExp(r'([\w.-]+)@([\w.-]+)', caseSensitive: false);
  static final RegExp _bankAccountRegExp = RegExp(r'(?:a/c|account|acct)[\s.]*(?:no|num)?[\s:]*([0-9Xx*.-]+)', caseSensitive: false);

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

    // Mask UPI IDs: john.doe@okhdfcbank -> john.***@okhdfcbank
    masked = masked.replaceAllMapped(_upiIdRegExp, (match) {
      final userPart = match.group(1)!;
      final bankPart = match.group(2)!;
      
      if (userPart.length > 3) {
        final visible = userPart.substring(0, 3);
        final maskedUser = visible + ('*' * (userPart.length - 3));
        return '$maskedUser@$bankPart';
      } else {
        return '${'*' * userPart.length}@$bankPart';
      }
    });

    // Mask Bank Accounts
    masked = masked.replaceAllMapped(_bankAccountRegExp, (match) {
      final account = match.group(1)!;
      final cleanAccount = account.replaceAll(RegExp(r'[^0-9Aa-z]'), '');
      
      if (cleanAccount.length > 4) {
        final last4 = cleanAccount.substring(cleanAccount.length - 4);
        return match.group(0)!.replaceFirst(account, '****$last4');
      } else {
        return match.group(0)!.replaceFirst(account, '****');
      }
    });

    // We do NOT mask amounts, as they are crucial for parsing intent (e.g., Collect Requests)
    return masked;
  }
}
