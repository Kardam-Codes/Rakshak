import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/engine/rule_engine.dart';
import 'package:rakshak/engine/models/risk_level.dart';
import 'package:rakshak/engine/models/scam_category.dart';
import 'package:rakshak/models/scan_entity.dart';

void main() {
  group('Safe Scan Rule Engine Tests', () {
    test('Detects raw IP address URLs as High/Critical risk phishing', () {
      final result = RuleEngine.analyzeScan('http://192.168.1.50/login.html', ScanType.url);
      expect(result.riskLevel, isIn([RiskLevel.medium, RiskLevel.high, RiskLevel.critical]));
      expect(result.matchedRules, contains('SCAN_IP_URL_01'));
      expect(result.category, ScamCategory.phishingWebsite);
    });

    test('Detects typosquatting domain impersonation', () {
      final result = RuleEngine.analyzeScan('https://paytmm.com/claim-reward', ScanType.url);
      expect(result.riskLevel, isIn([RiskLevel.medium, RiskLevel.high, RiskLevel.critical]));
      expect(result.matchedRules, contains('SCAN_TYPOSQUATTING_04'));
    });

    test('Detects UPI Collect Payment Request in QR code', () {
      final result = RuleEngine.analyzeScan('upi://pay?pa=scammer@ybl&am=5000&mode=02&collect=true', ScanType.qr);
      expect(result.riskLevel, isIn([RiskLevel.medium, RiskLevel.high, RiskLevel.critical]));
      expect(result.matchedRules, contains('SCAN_UPI_COLLECT_06'));
      expect(result.category, ScamCategory.collectRequest);
    });

    test('Detects direct APK executable download links', () {
      final result = RuleEngine.analyzeScan('http://unknown-server.site/bank-update.apk', ScanType.url);
      expect(result.riskLevel, isIn([RiskLevel.medium, RiskLevel.high, RiskLevel.critical]));
      expect(result.matchedRules, contains('SCAN_APK_DOWNLOAD_05'));
    });

    test('Safe standard domain passes with Safe or Low risk level', () {
      final result = RuleEngine.analyzeScan('https://sbi.co.in', ScanType.url);
      expect(result.riskLevel, isIn([RiskLevel.safe, RiskLevel.low]));
    });
  });
}
