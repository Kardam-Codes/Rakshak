import '../models/scan_entity.dart';
import 'models/detection_result.dart';
import 'models/risk_level.dart';
import 'models/scam_category.dart';
import 'models/scam_rule.dart';
import 'risk_scorer.dart';
import 'rule_engine.dart'; // Just needed to access _allRules or we can expose them. Wait, _allRules is private in RuleEngine.

// I need to import rules directly or expose _allRules.
import 'rules/otp_rules.dart';
import 'rules/kyc_rules.dart';
import 'rules/lottery_rules.dart';
import 'rules/upi_rules.dart';
import 'rules/loan_rules.dart';
import 'rules/refund_rules.dart';
import 'rules/investment_rules.dart';
import 'rules/general_rules.dart';
import 'rules/job_rules.dart';
import 'rules/call_rules.dart';
import 'rules/scan_rules.dart';

import 'validators/domain_checker.dart';
import 'validators/upi_validator.dart';
import 'validators/url_validator.dart';
import 'validators/validator.dart';

class ScanClassifier {
  static final List<ScamRule> _allRules = [
    ...otpRules,
    ...kycRules,
    ...lotteryRules,
    ...upiRules,
    ...loanRules,
    ...refundRules,
    ...investmentRules,
    ...generalRules,
    ...jobRules,
    ...scanRules,
  ];

  static final List<Validator> _validators = [
    UrlValidator(),
    DomainChecker(),
    UpiValidator(),
  ];

  static DetectionResult classify(String content, ScanType type) {
    final cleanContent = content.trim();
    final lowerContent = cleanContent.toLowerCase();

    // 1. Validation Phase
    List<ValidationResult> validationFailures = [];
    for (var validator in _validators) {
      final result = validator.validate(cleanContent, type);
      if (!result.isValid) {
        validationFailures.add(result);
      }
    }

    // 2. Offline Rule Engine Phase
    List<ScamRule> matchedRules = [];
    ScamCategory primaryCategory = ScamCategory.unknown;

    for (var rule in _allRules) {
      if (!rule.enabled) continue;
      bool isMatch = false;

      // Regex match
      if (rule.regex != null) {
        try {
          final regex = RegExp(rule.regex!, caseSensitive: false, unicode: true);
          if (regex.hasMatch(cleanContent)) {
            isMatch = true;
          }
        } catch (_) {}
      }

      // Keyword match
      if (!isMatch) {
        for (var keyword in rule.keywords) {
          if (lowerContent.contains(keyword.toLowerCase())) {
            isMatch = true;
            break;
          }
        }
      }

      if (isMatch) {
        matchedRules.add(rule);
        if (primaryCategory == ScamCategory.unknown && rule.category != ScamCategory.unknown) {
          primaryCategory = rule.category;
        }
      }
    }

     // 3. Risk Scoring Engine Phase
    final scoreResult = RiskScorer.calculateScore(matchedRules, validationFailed: validationFailures.isNotEmpty);
    
    // 4. Final Decision Construction
    String reason;
    String action;

    if (matchedRules.isEmpty && validationFailures.isEmpty) {
      reason = 'Valid URL. Known domain structure. No suspicious rules triggered.';
      action = 'Safe to proceed.';
    } else {
      final ruleNames = matchedRules.map((r) => '✓ ${r.name}').join('\n');
      final valNames = validationFailures.map((v) => '✓ ${v.reason}').join('\n');
      
      reason = 'Suspicious because:\n';
      if (validationFailures.isNotEmpty) reason += '$valNames\n';
      if (matchedRules.isNotEmpty) reason += ruleNames;
      
      if (matchedRules.isNotEmpty) {
        matchedRules.sort((a, b) => b.weight.compareTo(a.weight));
        action = matchedRules.first.recommendedAction;
      } else {
        action = validationFailures.first.recommendedAction ?? 'Unable to verify authenticity.';
      }
    }

    final confidence = matchedRules.isEmpty ? 0.95 : (matchedRules.length * 0.25).clamp(0.40, 0.95);

    return DetectionResult(
      riskLevel: scoreResult.level,
      confidence: confidence,
      category: matchedRules.isEmpty ? ScamCategory.unknown : primaryCategory,
      matchedRules: matchedRules.map((r) => r.id).toList(),
      reason: reason,
      recommendedAction: action,
      timestamp: DateTime.now(),
    );
  }
}
