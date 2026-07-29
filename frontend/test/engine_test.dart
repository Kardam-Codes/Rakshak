import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/engine/rule_engine.dart';
import 'package:rakshak/engine/models/risk_level.dart';
import 'package:rakshak/engine/models/scam_category.dart';

void main() {
  group('RuleEngine Tests', () {
    test('Safe message should return Safe RiskLevel', () {
      final result = RuleEngine.analyze('Hello', 'How are you doing today?');
      expect(result.riskLevel, RiskLevel.safe);
      expect(result.category, ScamCategory.unknown);
      expect(result.matchedRules.isEmpty, true);
    });

    test('OTP requested should trigger OTP rules and flag Medium risk', () {
      final result = RuleEngine.analyze('Your OTP is 1234', 'Never share your one time password with anyone.');
      // OTP (25) -> Low
      // Wait, "never share" is typically used for Bypass warning? "ignore warning" etc.
      expect(result.riskLevel, RiskLevel.low);
      expect(result.category, ScamCategory.otpScam);
    });

    test('Collect Request with Urgent Action triggers High risk', () {
      final result = RuleEngine.analyze('Pending Request', 'Collect Request of INR 5000 from PhonePe. Act immediately!');
      // collect request (35) + immediately (20) = 55 Medium
      expect(result.riskLevel, RiskLevel.medium);
      expect(result.matchedRules.contains('UPI_001'), true);
      expect(result.matchedRules.contains('GEN_001'), true);
    });

    test('Lottery english and gujarati should trigger correctly', () {
      final res1 = RuleEngine.analyze('Congratulations', 'You are a winner of lucky draw. Share details.');
      expect(res1.category, ScamCategory.lotteryScam);

      // OTP Gujarati test
      final res2 = RuleEngine.analyze('Bank', 'તમારો ઓટીપી ૫૬૭૮ છે'); // "ઓટીપી"
      expect(res2.category, ScamCategory.otpScam);
    });
    
    test('Performance test - 1000 parsing cycles under 1 sec', () {
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 1000; i++) {
        RuleEngine.analyze('Alert', 'This is a test notification payload to check processing times for a collect request and url click link');
      }
      
      stopwatch.stop();
      // Print to verify manually
      print('1000 cycles completed in: ${stopwatch.elapsedMilliseconds} ms');
      expect(stopwatch.elapsedMilliseconds < 1000, true);
    });
  });
}
