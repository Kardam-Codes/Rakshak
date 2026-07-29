import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/engine/rule_engine.dart';
import 'package:rakshak/engine/models/risk_level.dart';
import 'package:rakshak/engine/models/scam_category.dart';

void main() {
  group('Call Rule Engine Tests', () {
    test('Identifies explicitly hidden numbers', () {
      final result = RuleEngine.analyzeCall('unknown', 1.0);
      expect(result.riskLevel, isIn([RiskLevel.low, RiskLevel.medium, RiskLevel.high, RiskLevel.critical]));
      expect(result.category, equals(ScamCategory.unknown));
      expect(result.matchedRules.contains('CALL_HIDDEN'), isTrue);
    });

    test('Identifies foreign prefixes correctly', () {
      final result1 = RuleEngine.analyzeCall('+18005551234', 1.0);
      expect(result1.riskLevel, isNot(RiskLevel.safe));
      expect(result1.matchedRules.contains('CALL_UNKNOWN_01'), isTrue);

      final result91 = RuleEngine.analyzeCall('+919876543210', 1.0); // India prefix should not trigger foreign rule
      expect(result91.matchedRules.contains('CALL_UNKNOWN_01'), isFalse);
    });

    test('Reduces risk for known contacts', () {
      // It should still detect matched patterns, but overall risk should be dampened
      final resultKnown = RuleEngine.analyzeCall('+18005551234', 1.0, isKnownContact: true);
      final resultUnknown = RuleEngine.analyzeCall('+18005551234', 1.0, isKnownContact: false);
      
      // Known contact risk < Unknown contact risk if a rule was matched
      expect(resultKnown.riskLevel.index < resultUnknown.riskLevel.index, isTrue);
    });

    test('Identifies low reputation numbers', () {
      final result = RuleEngine.analyzeCall('+919876543210', 0.1); 
      expect(result.matchedRules.contains('CALL_LOW_REP'), isTrue);
    });
  });
}
