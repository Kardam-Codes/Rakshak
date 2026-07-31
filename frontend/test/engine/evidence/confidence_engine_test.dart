import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/engine/evidence/confidence_engine.dart';
import 'package:rakshak/engine/evidence/evidence_models.dart';

void main() {
  group('ConfidenceEngine', () {
    test('Offline only: high evidence gives 70% confidence (max 85 if no intel)', () {
      final evidence = [
        const EvidenceItem(
          category: EvidenceCategory.offlineRule,
          severity: EvidenceSeverity.high,
          reason: 'Matched offline rule',
        )
      ];

      final score = ConfidenceEngine.calculateConfidence(evidence, false);
      expect(score.percentage, 70);
      expect(score.confidenceLevel, EvidenceSeverity.medium);
    });

    test('Offline only: safe gives 85% confidence (capped)', () {
      final evidence = <EvidenceItem>[];
      final score = ConfidenceEngine.calculateConfidence(evidence, false);
      expect(score.percentage, 85);
      expect(score.confidenceLevel, EvidenceSeverity.high);
    });

    test('Online: High consensus on bad gives 98%', () {
      final evidence = [
        const EvidenceItem(
          category: EvidenceCategory.offlineRule,
          severity: EvidenceSeverity.critical,
          reason: 'Matched offline rule',
        ),
        const EvidenceItem(
          category: EvidenceCategory.threatIntelligence,
          severity: EvidenceSeverity.critical,
          reason: 'Malicious intel',
        )
      ];

      final score = ConfidenceEngine.calculateConfidence(evidence, true);
      expect(score.percentage, 98);
      expect(score.confidenceLevel, EvidenceSeverity.high);
    });

    test('Online: High consensus on safe gives 99%', () {
      final evidence = [
        const EvidenceItem(
          category: EvidenceCategory.threatIntelligence,
          severity: EvidenceSeverity.low,
          reason: 'Clean intel',
        )
      ];

      final score = ConfidenceEngine.calculateConfidence(evidence, true);
      expect(score.percentage, 99);
      expect(score.confidenceLevel, EvidenceSeverity.high);
    });

    test('Online: Conflict (Offline bad, Intel clean) lowers confidence to 65%', () {
      final evidence = [
        const EvidenceItem(
          category: EvidenceCategory.offlineRule,
          severity: EvidenceSeverity.high,
          reason: 'Matched offline rule',
        ),
        const EvidenceItem(
          category: EvidenceCategory.threatIntelligence,
          severity: EvidenceSeverity.low,
          reason: 'Clean intel',
        )
      ];

      final score = ConfidenceEngine.calculateConfidence(evidence, true);
      expect(score.percentage, 65);
      expect(score.confidenceLevel, EvidenceSeverity.medium);
    });
  });
}
