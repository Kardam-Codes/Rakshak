import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/engine/models/detection_result.dart';
import 'package:rakshak/engine/models/risk_level.dart';
import 'package:rakshak/engine/models/scam_category.dart';
import 'package:rakshak/engine/threat/decision_merger.dart';
import 'package:rakshak/engine/threat/threat_models.dart';

void main() {
  group('DecisionMerger', () {
    DetectionResult createResult(RiskLevel level, String reason) {
      return DetectionResult(
        riskLevel: level,
        confidence: 0.9,
        category: ScamCategory.unknown,
        matchedRules: [],
        reason: reason,
        recommendedAction: '',
        timestamp: DateTime.now(),
      );
    }

    test('Offline Safe + All Clean = Safe', () {
      final offline = createResult(RiskLevel.safe, 'Valid URL. Known domain structure. No suspicious rules triggered.');
      final summary = ThreatSummary(
        results: [
          ThreatResult(provider: 'Google', status: ThreatStatus.clean, confidence: 99, reason: 'Clean', responseTimeMs: 100),
          ThreatResult(provider: 'VirusTotal', status: ThreatStatus.clean, confidence: 99, reason: 'Clean', responseTimeMs: 100),
        ],
        timestamp: DateTime.now(),
      );

      final decision = DecisionMerger.merge(offline, summary);
      expect(decision.riskLevel, RiskLevel.safe);
      expect(decision.structuredEvidence['threatIntelligence'], contains('Google reports clean.'));
    });

    test('Offline Safe + Google Malicious = Dangerous', () {
      final offline = createResult(RiskLevel.safe, 'Valid URL. Known domain structure. No suspicious rules triggered.');
      final summary = ThreatSummary(
        results: [
          ThreatResult(provider: 'Google', status: ThreatStatus.malicious, confidence: 99, reason: 'Phishing', responseTimeMs: 100),
        ],
        timestamp: DateTime.now(),
      );

      final decision = DecisionMerger.merge(offline, summary);
      expect(decision.riskLevel, RiskLevel.critical);
    });

    test('Offline Suspicious + Clean intel = Suspicious', () {
      final offline = createResult(RiskLevel.medium, 'Suspicious because:\n✓ Matched some offline rule');
      final summary = ThreatSummary(
        results: [
          ThreatResult(provider: 'VirusTotal', status: ThreatStatus.clean, confidence: 99, reason: 'Clean', responseTimeMs: 100),
        ],
        timestamp: DateTime.now(),
      );

      final decision = DecisionMerger.merge(offline, summary);
      expect(decision.riskLevel, RiskLevel.medium);
    });

    test('Offline Validation Failure + Clean intel = Suspicious (no downgrade)', () {
      final offline = createResult(RiskLevel.medium, 'Suspicious because:\n✓ Unable to verify authenticity.');
      final summary = ThreatSummary(
        results: [
          ThreatResult(provider: 'Google', status: ThreatStatus.clean, confidence: 99, reason: 'Clean', responseTimeMs: 100),
        ],
        timestamp: DateTime.now(),
      );

      final decision = DecisionMerger.merge(offline, summary);
      expect(decision.riskLevel, RiskLevel.medium); // Never lowers below medium if validation failed
    });
    
    test('Offline Unavailable (null summary) returns offline rules', () {
      final offline = createResult(RiskLevel.high, 'Suspicious because:\n✓ Test Rule');
      
      final decision = DecisionMerger.merge(offline, null);
      expect(decision.riskLevel, RiskLevel.high);
      expect(decision.structuredEvidence['threatIntelligence']?.first, contains('Online verification unavailable'));
    });
  });
}
