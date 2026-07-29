import 'models/risk_level.dart';
import 'models/scam_rule.dart';

class RiskCalculator {
  static RiskLevel calculateRiskLevel(List<ScamRule> matchedRules) {
    int totalWeight = _calculateTotalWeight(matchedRules);

    if (totalWeight <= 20) {
      return RiskLevel.safe;
    } else if (totalWeight <= 40) {
      return RiskLevel.low;
    } else if (totalWeight <= 60) {
      return RiskLevel.medium;
    } else if (totalWeight <= 80) {
      return RiskLevel.high;
    } else {
      return RiskLevel.critical;
    }
  }

  static int _calculateTotalWeight(List<ScamRule> matchedRules) {
    int total = 0;
    for (var rule in matchedRules) {
      total += rule.weight;
    }
    return total;
  }
}
