import 'risk_level.dart';
import 'scam_category.dart';

class DetectionResult {
  final RiskLevel riskLevel;
  final double confidence;
  final ScamCategory category;
  final List<String> matchedRules;
  final String reason;
  final String recommendedAction;
  final DateTime timestamp;

  const DetectionResult({
    required this.riskLevel,
    required this.confidence,
    required this.category,
    required this.matchedRules,
    required this.reason,
    required this.recommendedAction,
    required this.timestamp,
  });
}
