import '../models/risk_level.dart';

enum ThreatStatus {
  clean,
  malicious,
  not_found,
  error
}

class ThreatResult {
  final String provider;
  final ThreatStatus status;
  final int confidence;
  final String reason;
  final int responseTimeMs;
  final int detections;

  ThreatResult({
    required this.provider,
    required this.status,
    required this.confidence,
    required this.reason,
    required this.responseTimeMs,
    this.detections = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'status': status.name,
      'confidence': confidence,
      'reason': reason,
      'response_time': responseTimeMs,
      'detections': detections,
    };
  }
}

class ThreatSummary {
  final List<ThreatResult> results;
  final DateTime timestamp;

  ThreatSummary({
    required this.results,
    required this.timestamp,
  });
}

class MergedDecision {
  final RiskLevel riskLevel;
  final Map<String, List<String>> structuredEvidence;
  final bool usedThreatIntelligence;

  MergedDecision({
    required this.riskLevel,
    required this.structuredEvidence,
    this.usedThreatIntelligence = false,
  });
}

abstract class ThreatProvider {
  Future<ThreatResult> analyze(String url);
}
