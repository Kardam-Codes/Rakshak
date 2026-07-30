import 'models/scam_rule.dart';
import 'models/scam_category.dart';
import 'models/detection_result.dart';
import 'models/risk_level.dart';
import 'models/transaction_type.dart';
import 'risk_calculator.dart';
import 'rules/otp_rules.dart';
import 'rules/kyc_rules.dart';
import 'rules/lottery_rules.dart';
import 'rules/upi_rules.dart';
import 'rules/loan_rules.dart';
import 'rules/refund_rules.dart';
import 'rules/investment_rules.dart';
import 'rules/general_rules.dart';
import 'rules/call_rules.dart';
import 'rules/scan_rules.dart';
import '../models/scan_entity.dart';

class RuleEngine {
  static final List<ScamRule> _allRules = [
    ...otpRules,
    ...kycRules,
    ...lotteryRules,
    ...upiRules,
    ...loanRules,
    ...refundRules,
    ...investmentRules,
    ...generalRules,
    ...scanRules,
  ];

  static DetectionResult analyze(String title, String body) {
    final combinedText = '$title $body';
    // Normalize string: Lowercase, remove basic punctuation for clean keyword matching.
    // Keeps alphanumeric and Gujarati unicode block (U+0A80 - U+0AFF).
    final normalizedText = combinedText
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s\u0A80-\u0AFF]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');

    List<ScamRule> matchedRules = [];
    ScamCategory primaryCategory = ScamCategory.unknown;

    for (var rule in _allRules) {
      if (!rule.enabled) continue;

      bool isMatch = false;

      // Regex matching
      if (rule.regex != null) {
        final regex = RegExp(rule.regex!, caseSensitive: false, unicode: true);
        if (regex.hasMatch(combinedText)) {
          isMatch = true;
        }
      }

      // Keyword matching
      if (!isMatch) {
         for (var keyword in rule.keywords) {
           final normalizedKeyword = keyword.toLowerCase();
           // Strict word boundary check might fail with Gujarati, simple contains is safer 
           // when punctuation is already stripped.
           if (normalizedText.contains(normalizedKeyword)) {
             isMatch = true;
             break;
           }
         }
      }

      if (isMatch) {
        matchedRules.add(rule);
        // Determine the most specific category (not unknown) from matches
        if (primaryCategory == ScamCategory.unknown && rule.category != ScamCategory.unknown) {
          primaryCategory = rule.category;
        }
      }
    }

    final riskLevel = RiskCalculator.calculateRiskLevel(matchedRules);
    
    // Compile reason string
    String reason = 'Message appears safe.';
    String action = 'No action required.';
    
    if (matchedRules.isNotEmpty) {
      final names = matchedRules.map((r) => r.name).join(', ');
      reason = 'Detected potential risk patterns: $names.';
      
      // Select action from highest weighted rule
      matchedRules.sort((a, b) => b.weight.compareTo(a.weight));
      action = matchedRules.first.recommendedAction;
    }

    final confidence = matchedRules.isEmpty ? 1.0 : (matchedRules.length * 0.2).clamp(0.0, 0.95);

    return DetectionResult(
      riskLevel: riskLevel,
      confidence: confidence,
      category: matchedRules.isEmpty ? ScamCategory.unknown : primaryCategory,
      matchedRules: matchedRules.map((r) => r.id).toList(),
      reason: reason,
      recommendedAction: action,
      timestamp: DateTime.now(),
    );
  }

  static DetectionResult analyzeCall(String phoneNumber, double reputation, {bool isKnownContact = false}) {
    List<ScamRule> matchedRules = [];
    ScamCategory primaryCategory = ScamCategory.unknown;

    if (!isKnownContact) {
      for (var rule in callRules) {
        if (!rule.enabled) continue;
        bool isMatch = false;

        if (rule.id == 'CALL_UNKNOWN_01' && (phoneNumber.startsWith('+1') || phoneNumber.startsWith('+44') || phoneNumber.startsWith('+92'))) {
          isMatch = true;
        } else if (rule.id == 'CALL_ROBOCALL_PREFIX' && phoneNumber.startsWith('140')) {
          isMatch = true;
        } else if (rule.id == 'CALL_HIDDEN' && (phoneNumber.isEmpty || phoneNumber.toLowerCase() == 'unknown' || phoneNumber.toLowerCase() == 'private')) {
          isMatch = true;
        }

        if (isMatch) {
          matchedRules.add(rule);
          primaryCategory = rule.category;
        }
      }
    }

    if (reputation < 0.3) {
      matchedRules.add(const ScamRule(
        id: 'CALL_LOW_REP',
        name: 'Low Reputation Score',
        description: 'Number flagged by reputation network',
        keywords: [],
        weight: 35,
        category: ScamCategory.unknown,
        recommendedAction: 'Do not answer or engage. Number is flagged by community.',
      ));
    }

    var riskLevel = RiskCalculator.calculateRiskLevel(matchedRules);
    
    // Reduce risk if known contact
    if (isKnownContact && riskLevel != RiskLevel.safe) {
      if (riskLevel == RiskLevel.critical) riskLevel = RiskLevel.high;
      else if (riskLevel == RiskLevel.high) riskLevel = RiskLevel.medium;
      else riskLevel = RiskLevel.low;
    }

    String reason = 'Call appears safe.';
    String action = 'No action required.';
    
    if (matchedRules.isNotEmpty) {
      final names = matchedRules.map((r) => r.name).join(', ');
      reason = 'Detected potential risk patterns: $names.';
      
      matchedRules.sort((a, b) => b.weight.compareTo(a.weight));
      action = matchedRules.first.recommendedAction;
    }

    return DetectionResult(
      riskLevel: riskLevel,
      confidence: 0.9,
      category: matchedRules.isEmpty ? ScamCategory.unknown : primaryCategory,
      matchedRules: matchedRules.map((r) => r.id).toList(),
      reason: reason,
      recommendedAction: action,
      timestamp: DateTime.now(),
    );
  }

  static DetectionResult analyzeUPI({
    required String merchantName,
    required String upiId,
    required TransactionType type,
    required double amount,
    required String title,
    required String body,
    bool isKnownContact = false,
  }) {
    // 1. Run standard textual analysis (including UPI rules like KYC, Reward, Urgent)
    DetectionResult baseResult = analyze(title, body);

    List<ScamRule> additionalRules = [];
    ScamCategory primaryCategory = baseResult.category;

    // 2. Evaluate UPI-specific situational characteristics
    if (!isKnownContact && upiId.isNotEmpty) {
      final unknownRule = upiRules.firstWhere((r) => r.id == 'UPI_UNKNOWN_ID', orElse: () => upiRules.first);
      if (unknownRule.id == 'UPI_UNKNOWN_ID') {
         additionalRules.add(unknownRule);
      }
    }

    if (type == TransactionType.collectRequest) {
      final collectRule = upiRules.firstWhere((r) => r.id == 'UPI_COLLECT_REQUEST', orElse: () => upiRules.first);
      if (collectRule.id == 'UPI_COLLECT_REQUEST') {
         additionalRules.add(collectRule);
         primaryCategory = ScamCategory.collectRequest;
      }
    }

    // High amount without known contact
    if (amount > 10000 && !isKnownContact) {
      additionalRules.add(const ScamRule(
        id: 'UPI_HIGH_AMOUNT',
        name: 'High Amount Transfer',
        description: 'Large transaction requested to unknown entity.',
        keywords: [],
        weight: 25,
        category: ScamCategory.unknown,
        recommendedAction: 'Verify the identity of the recipient before proceeding with a large transfer.',
      ));
    }

    // Combine rules
    List<String> allMatchedIds = List.from(baseResult.matchedRules);
    for (var rule in additionalRules) {
      if (!allMatchedIds.contains(rule.id)) {
        allMatchedIds.add(rule.id);
      }
    }

    // Re-calculate risk (We need full ScamRule object for RiskCalculator, so we need to fetch them from base)
    List<ScamRule> activeRules = _allRules.where((r) => allMatchedIds.contains(r.id)).toList();
    if (additionalRules.any((r) => r.id == 'UPI_HIGH_AMOUNT')) {
       activeRules.add(additionalRules.firstWhere((r) => r.id == 'UPI_HIGH_AMOUNT'));
    }

    var finalRiskLevel = RiskCalculator.calculateRiskLevel(activeRules);

    // Dampen risk if known contact
    if (isKnownContact && finalRiskLevel != RiskLevel.safe) {
      if (finalRiskLevel == RiskLevel.critical) finalRiskLevel = RiskLevel.high;
      else if (finalRiskLevel == RiskLevel.high) finalRiskLevel = RiskLevel.medium;
      else finalRiskLevel = RiskLevel.low;
    } else if (!isKnownContact && type == TransactionType.collectRequest) {
      // Force high risk for any unknown collect request
      if (finalRiskLevel == RiskLevel.safe || finalRiskLevel == RiskLevel.low || finalRiskLevel == RiskLevel.medium) {
         finalRiskLevel = RiskLevel.high;
      }
    }

    String reason = 'UPI transaction appears safe.';
    String action = 'Proceed normally.';

    if (activeRules.isNotEmpty) {
       activeRules.sort((a,b) => b.weight.compareTo(a.weight));
       reason = 'Detected risk logic: ${activeRules.map((e) => e.name).join(', ')}.';
       action = activeRules.first.recommendedAction;
    }

    double confidence = activeRules.isEmpty ? 1.0 : (activeRules.length * 0.25).clamp(0.0, 0.95);

    return DetectionResult(
      riskLevel: finalRiskLevel,
      confidence: confidence,
      category: activeRules.isEmpty ? ScamCategory.unknown : (primaryCategory != ScamCategory.unknown ? primaryCategory : activeRules.first.category),
      matchedRules: allMatchedIds,
      reason: reason,
      recommendedAction: action,
      timestamp: DateTime.now(),
    );
  }

  static DetectionResult analyzeScan(String content, ScanType type) {
    final cleanContent = content.trim();
    final lowerContent = cleanContent.toLowerCase();

    List<ScamRule> matchedRules = [];
    ScamCategory primaryCategory = ScamCategory.unknown;

    // Run against all rules
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

    // Special type-specific fallback rules
    if (type == ScanType.qr && lowerContent.startsWith('upi://pay')) {
      if (matchedRules.isEmpty) {
        primaryCategory = ScamCategory.qrScam;
      }
    } else if (type == ScanType.url && (lowerContent.startsWith('http://') || lowerContent.startsWith('https://'))) {
      if (matchedRules.isEmpty) {
        primaryCategory = ScamCategory.unknown;
      }
    }

    final riskLevel = RiskCalculator.calculateRiskLevel(matchedRules);

    String reason = 'Based on available analysis, no known threat patterns were detected.';
    String action = 'Always verify the sender before opening links or making payments.';

    if (matchedRules.isNotEmpty) {
      final ruleNames = matchedRules.map((r) => r.name).join(', ');
      reason = 'Matched security rules: $ruleNames.';
      matchedRules.sort((a, b) => b.weight.compareTo(a.weight));
      action = matchedRules.first.recommendedAction;
    }

    final confidence = matchedRules.isEmpty ? 0.95 : (matchedRules.length * 0.25).clamp(0.40, 0.95);

    return DetectionResult(
      riskLevel: riskLevel,
      confidence: confidence,
      category: matchedRules.isEmpty ? ScamCategory.unknown : primaryCategory,
      matchedRules: matchedRules.map((r) => r.id).toList(),
      reason: reason,
      recommendedAction: action,
      timestamp: DateTime.now(),
    );
  }
}


