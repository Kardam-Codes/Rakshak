import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/engine/models/transaction_type.dart';
import 'package:rakshak/engine/rule_engine.dart';
import 'package:rakshak/engine/models/risk_level.dart';
import 'package:rakshak/engine/models/scam_category.dart';
import 'package:rakshak/utils/pii_masking.dart';

void main() {
  group('RuleEngine - UPI Analysis', () {
    test('Identifies Safe Payment correctly', () {
      final result = RuleEngine.analyzeUPI(
        merchantName: 'Swiggy',
        upiId: 'swiggy@okhdfcbank',
        type: TransactionType.payment,
        amount: 350.0,
        title: 'Paid Swiggy',
        body: 'Paid Rs. 350 for food delivery.',
        isKnownContact: true,
      );

      expect(result.riskLevel, RiskLevel.safe);
    });

    test('Identifies Collect Request correctly', () {
      final result = RuleEngine.analyzeUPI(
        merchantName: 'Random Scammer',
        upiId: 'scammer@ybl',
        type: TransactionType.collectRequest,
        amount: 5000.0,
        title: 'Payment Requested',
        body: 'Random Scammer has requested money from you. Enter PIN to receive.', 
        isKnownContact: false,
      );

      expect(result.riskLevel, RiskLevel.high);
      expect(result.category, ScamCategory.collectRequest);
    });

    test('Identifies Refund Scam Urgency', () {
      final result = RuleEngine.analyzeUPI(
        merchantName: 'Refund Dept',
        upiId: '',
        type: TransactionType.refund,
        amount: 25000.0,
        title: 'Refund Processing',
        body: 'Your refund of 25,000 has failed. Click immediately to reverse the amount.',
        isKnownContact: false,
      );

      expect(result.riskLevel, RiskLevel.critical);
      expect(result.matchedRules.contains('UPI_REFUND_TRICK'), isTrue);
      // Urgency + High Amount + Refund trick -> likely critical or high
    });
  });

  group('PII Masking', () {
    test('Masks standard UPI IDs correctly', () {
      final text = "Paid john.doe@okhdfcbank yesterday.";
      final masked = PIIMasking.maskData(text);
      expect(masked, "Paid joh*****@okhdfcbank yesterday.");
    });

    test('Masks short UPI IDs correctly', () {
      final text = "Paid io@sbi.";
      final masked = PIIMasking.maskData(text);
      expect(masked, "Paid **@sbi.");
    });

    test('Masks Bank Accounts correctly', () {
      final text = "Sent to a/c 123456789012";
      final masked = PIIMasking.maskData(text);
      // The word '123456789012' should be partially masked '****9012'
      expect(masked, "Sent to a/c ****9012");
    });

    test('Leaves amounts visible', () {
      final text = "Requested Rs. 5,000 to john.doe@ybl";
      final masked = PIIMasking.maskData(text);
      expect(masked, "Requested Rs. 5,000 to joh*****@ybl");
    });
  });
}
