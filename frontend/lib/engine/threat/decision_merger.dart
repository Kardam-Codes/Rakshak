import '../models/detection_result.dart';
import '../models/risk_level.dart';
import 'threat_models.dart';

class DecisionMerger {
  static MergedDecision merge(DetectionResult offlineResult, ThreatSummary? threatSummary) {
    List<String> offlineReasons = [];
    if (offlineResult.reason.isNotEmpty && offlineResult.reason != 'Valid URL. Known domain structure. No suspicious rules triggered.') {
      // Split if it's our multiline string format
      if (offlineResult.reason.startsWith('Suspicious because:')) {
        final parts = offlineResult.reason.replaceFirst('Suspicious because:\n', '').split('\n');
        offlineReasons.addAll(parts.map((p) => p.replaceFirst('✓ ', '').trim()));
      } else {
        offlineReasons.add(offlineResult.reason);
      }
    }

    if (threatSummary == null || threatSummary.results.isEmpty) {
      return MergedDecision(
        riskLevel: offlineResult.riskLevel,
        structuredEvidence: {
          'offlineReasons': offlineReasons,
          'threatIntelligence': ['Online verification unavailable. Analysis performed using Rakshak Offline Security Engine.']
        },
        usedThreatIntelligence: false,
      );
    }

    List<String> threatIntelligence = [];
    RiskLevel finalRiskLevel = offlineResult.riskLevel;
    
    // Check if offline failure is due to validation (which shouldn't be overridden to Safe)
    bool hasValidationFailure = offlineReasons.any((r) => r.contains('failed strict validation') || r.contains('Unable to verify') || r.contains('domain') || r.contains('scheme') || r.contains('IP'));

    bool anyMalicious = false;
    for (var result in threatSummary.results) {
      if (result.status == ThreatStatus.malicious) {
        anyMalicious = true;
        if (result.provider == 'VirusTotal') {
          threatIntelligence.add('${result.provider} flagged by ${result.detections} engines.');
        } else {
          threatIntelligence.add('${result.provider} detected malicious activity: ${result.reason}');
        }
      } else if (result.status == ThreatStatus.clean) {
        threatIntelligence.add('${result.provider} reports clean.');
      }
    }

    if (anyMalicious) {
      // Increase risk to Critical (Dangerous) if any provider says malicious
      finalRiskLevel = RiskLevel.critical;
    } else {
      // All providers clean
      if (!hasValidationFailure && finalRiskLevel != RiskLevel.critical) {
        // We do not decrease critical offline rules unless we have huge confidence, 
        // but the prompt says: "Never allow Threat Intelligence to override validation failures."
        // Example: Offline Safe, Everything Clean -> Safe
        // If offline is Suspicious, but validation didn't fail, maybe we lower it? 
        // The prompt says: "Offline Suspicious, VirusTotal Clean -> Suspicious". So we don't lower it!
        // Threat intel only *increases* confidence (i.e. increases risk level if malicious, but doesn't lower it if offline found something).
        // So finalRiskLevel stays the same.
      }
    }

    if (threatIntelligence.isEmpty) {
       threatIntelligence.add('Providers checked but no significant intelligence found.');
    }

    return MergedDecision(
      riskLevel: finalRiskLevel,
      structuredEvidence: {
        'offlineReasons': offlineReasons,
        'threatIntelligence': threatIntelligence,
      },
      usedThreatIntelligence: true,
    );
  }
}
