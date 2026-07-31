enum EvidenceCategory {
  validation,
  offlineRule,
  threatIntelligence,
  riskScore
}

enum EvidenceSeverity {
  low,
  medium,
  high,
  critical
}

class EvidenceItem {
  final EvidenceCategory category;
  final EvidenceSeverity severity;
  final String reason;

  const EvidenceItem({
    required this.category,
    required this.severity,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'severity': severity.name,
      'reason': reason,
    };
  }

  factory EvidenceItem.fromJson(Map<String, dynamic> json) {
    return EvidenceItem(
      category: EvidenceCategory.values.firstWhere((e) => e.name == json['category'], orElse: () => EvidenceCategory.offlineRule),
      severity: EvidenceSeverity.values.firstWhere((e) => e.name == json['severity'], orElse: () => EvidenceSeverity.low),
      reason: json['reason'] as String,
    );
  }
}

class ConfidenceScore {
  final int percentage; // 0-100
  final EvidenceSeverity confidenceLevel;

  const ConfidenceScore({
    required this.percentage,
    required this.confidenceLevel,
  });

  String get displayString {
    if (percentage >= 85) return 'High Confidence';
    if (percentage >= 60) return 'Medium Confidence';
    return 'Low Confidence';
  }
}
