import '../models/risk_level.dart';
import 'evidence_models.dart';

class EvidenceBuilder {
  static List<EvidenceItem> buildEvidence({
    required Map<String, List<String>> structuredEvidence,
    required RiskLevel riskLevel,
  }) {
    final List<EvidenceItem> evidence = [];

    final offlineReasons = structuredEvidence['offlineReasons'] ?? [];
    for (var reason in offlineReasons) {
      if (reason.contains('validation') || reason.contains('domain') || reason.contains('Unable to verify')) {
        evidence.add(EvidenceItem(
          category: EvidenceCategory.validation,
          severity: EvidenceSeverity.medium,
          reason: reason,
        ));
      } else {
        evidence.add(EvidenceItem(
          category: EvidenceCategory.offlineRule,
          severity: riskLevel == RiskLevel.critical ? EvidenceSeverity.critical : EvidenceSeverity.high,
          reason: reason,
        ));
      }
    }

    final threatIntel = structuredEvidence['threatIntelligence'] ?? [];
    for (var intel in threatIntel) {
      if (intel.contains('malicious') || intel.contains('phishing') || intel.contains('flagged')) {
        evidence.add(EvidenceItem(
          category: EvidenceCategory.threatIntelligence,
          severity: EvidenceSeverity.critical,
          reason: intel,
        ));
      } else if (intel.contains('clean')) {
        // We usually don't show clean intel in the warning reasons, but it's evidence
        evidence.add(EvidenceItem(
          category: EvidenceCategory.threatIntelligence,
          severity: EvidenceSeverity.low,
          reason: intel,
        ));
      } else if (intel.contains('unavailable')) {
        evidence.add(EvidenceItem(
          category: EvidenceCategory.threatIntelligence,
          severity: EvidenceSeverity.medium,
          reason: intel,
        ));
      }
    }

    return evidence;
  }
}
