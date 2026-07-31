import 'evidence_models.dart';

class ConfidenceEngine {
  static ConfidenceScore calculateConfidence(List<EvidenceItem> evidence, bool usedThreatIntelligence) {
    int percentage = 50; // Base baseline

    int criticalEvidence = evidence.where((e) => e.severity == EvidenceSeverity.critical).length;
    int highEvidence = evidence.where((e) => e.severity == EvidenceSeverity.high).length;
    int mediumEvidence = evidence.where((e) => e.severity == EvidenceSeverity.medium).length;

    // Base score depending on offline severity
    if (criticalEvidence > 0) percentage = 80;
    else if (highEvidence > 0) percentage = 70;
    else if (mediumEvidence > 0) percentage = 60;
    else percentage = 90; // If no bad evidence, we are fairly confident it's safe

    // Boost confidence if we used Threat Intel
    if (usedThreatIntelligence) {
      bool hasMaliciousIntel = evidence.any((e) => 
          e.category == EvidenceCategory.threatIntelligence && 
          e.severity == EvidenceSeverity.critical);
      
      bool hasCleanIntel = evidence.any((e) => 
          e.category == EvidenceCategory.threatIntelligence && 
          e.severity == EvidenceSeverity.low); // Clean is mapped to low in EvidenceBuilder

      if (criticalEvidence > 0 && hasMaliciousIntel) {
        // High consensus: Offline bad, Intel bad
        percentage = 98;
      } else if (criticalEvidence == 0 && highEvidence == 0 && mediumEvidence == 0 && hasCleanIntel) {
        // High consensus: Offline safe, Intel clean
        percentage = 99;
      } else if (hasMaliciousIntel) {
        // Threat intel found something bad, even if offline didn't
        percentage = 95;
      } else if (hasCleanIntel && (highEvidence > 0 || mediumEvidence > 0)) {
        // Conflict: Offline says bad, Intel says clean. Lowers confidence.
        percentage = 65;
      }
    } else {
      // If we didn't use threat intel, max confidence is capped since we only have half the picture
      if (percentage > 85) percentage = 85; 
    }

    EvidenceSeverity level;
    if (percentage >= 85) level = EvidenceSeverity.high;
    else if (percentage >= 60) level = EvidenceSeverity.medium;
    else level = EvidenceSeverity.low;

    return ConfidenceScore(percentage: percentage, confidenceLevel: level);
  }
}
