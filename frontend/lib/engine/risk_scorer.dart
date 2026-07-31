import 'models/risk_level.dart';
import 'models/scam_rule.dart';

class RiskScorer {
  /// Calculates the risk score and final risk level based on triggered rules.
  static RiskScoreResult calculateScore(List<ScamRule> rules, {bool validationFailed = false}) {
    int totalScore = 0;
    for (var rule in rules) {
      totalScore += rule.weight;
    }

    RiskLevel level;
    if (totalScore <= 20) {
      level = validationFailed ? RiskLevel.medium : RiskLevel.safe;
    } else if (totalScore <= 49) {
      level = RiskLevel.medium; // Suspicious
    } else {
      level = RiskLevel.critical; // Dangerous
    }

    return RiskScoreResult(score: totalScore, level: level);
  }
}

class RiskScoreResult {
  final int score;
  final RiskLevel level;

  RiskScoreResult({required this.score, required this.level});
}
