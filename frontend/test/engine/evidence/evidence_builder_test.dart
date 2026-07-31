import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/engine/models/risk_level.dart';
import 'package:rakshak/engine/evidence/evidence_builder.dart';
import 'package:rakshak/engine/evidence/evidence_models.dart';

void main() {
  group('EvidenceBuilder', () {
    test('buildEvidence maps validation correctly', () {
      final evidence = EvidenceBuilder.buildEvidence(
        structuredEvidence: {
          'offlineReasons': ['domain validation failed'],
        },
        riskLevel: RiskLevel.medium,
      );

      expect(evidence.length, 1);
      expect(evidence.first.category, EvidenceCategory.validation);
      expect(evidence.first.severity, EvidenceSeverity.medium);
    });

    test('buildEvidence maps offline rules based on risk level', () {
      final evidence = EvidenceBuilder.buildEvidence(
        structuredEvidence: {
          'offlineReasons': ['Found in suspicious keywords'],
        },
        riskLevel: RiskLevel.critical,
      );

      expect(evidence.length, 1);
      expect(evidence.first.category, EvidenceCategory.offlineRule);
      expect(evidence.first.severity, EvidenceSeverity.critical);
    });

    test('buildEvidence maps malicious threat intel as critical', () {
      final evidence = EvidenceBuilder.buildEvidence(
        structuredEvidence: {
          'threatIntelligence': ['Google Safe Browsing: malicious'],
        },
        riskLevel: RiskLevel.safe,
      );

      expect(evidence.length, 1);
      expect(evidence.first.category, EvidenceCategory.threatIntelligence);
      expect(evidence.first.severity, EvidenceSeverity.critical);
    });

    test('buildEvidence handles empty maps', () {
      final evidence = EvidenceBuilder.buildEvidence(
        structuredEvidence: {},
        riskLevel: RiskLevel.safe,
      );

      expect(evidence.isEmpty, true);
    });
  });
}
