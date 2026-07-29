import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/utils/pii_masking.dart';

void main() {
  group('PII Masking utility Tests', () {
    test('Should mask OTP numbers', () {
      final text = "Your OTP is 123456. Do not share it.";
      final masked = PIIMasking.maskData(text);
      expect(masked, "Your OTP is ******. Do not share it.");
    });

    test('Should mask multi-part debit card numbers', () {
      final text = "Transaction of ₹50 on card ending with 4111 1234 5678 9010 declined.";
      final masked = PIIMasking.maskData(text);
      expect(masked, "Transaction of ₹50 on card ending with **************** declined.");
    });

    test('Should mask UPI PIN explicitly', () {
      final text = "Enter UPI PIN 1234 to proceed.";
      final masked = PIIMasking.maskData(text);
      expect(masked, "Enter UPI PIN **** to proceed.");
    });

    test('Should retain amount parsing context without masking numbers', () {
      final text = "Request to receive RS 500 from sender.";
      final masked = PIIMasking.maskData(text);
      expect(masked, "Request to receive RS 500 from sender."); // Doesn't match 4-8 digit block natively
    });
  });
}
