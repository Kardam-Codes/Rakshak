import '../engine/models/risk_level.dart';
import '../engine/models/scam_category.dart';

enum ScanType {
  qr,
  url,
  image,
  screenshot,
  text
}

extension ScanTypeExtension on ScanType {
  String get displayName {
    switch (this) {
      case ScanType.qr:
        return 'QR Code';
      case ScanType.url:
        return 'Website URL';
      case ScanType.image:
        return 'Gallery Image';
      case ScanType.screenshot:
        return 'Screenshot';
      case ScanType.text:
        return 'Plain Text';
    }
  }
}

class ScanResultEntity {
  final int? id;
  final String content;
  final ScanType scanType;
  final RiskLevel riskLevel;
  final double confidence;
  final ScamCategory category;
  final List<String> matchedRules;
  final String offlineReason;
  final String recommendedAction;
  final String? aiSimpleExplanation;
  final String? aiReason;
  final String? aiRecommendedAction;
  final String? aiShortSummary;
  final DateTime timestamp;
  final int processingTimeMs;

  ScanResultEntity({
    this.id,
    required this.content,
    required this.scanType,
    required this.riskLevel,
    required this.confidence,
    required this.category,
    required this.matchedRules,
    required this.offlineReason,
    required this.recommendedAction,
    this.aiSimpleExplanation,
    this.aiReason,
    this.aiRecommendedAction,
    this.aiShortSummary,
    required this.timestamp,
    required this.processingTimeMs,
  });

  ScanResultEntity copyWith({
    int? id,
    String? content,
    ScanType? scanType,
    RiskLevel? riskLevel,
    double? confidence,
    ScamCategory? category,
    List<String>? matchedRules,
    String? offlineReason,
    String? recommendedAction,
    String? aiSimpleExplanation,
    String? aiReason,
    String? aiRecommendedAction,
    String? aiShortSummary,
    DateTime? timestamp,
    int? processingTimeMs,
  }) {
    return ScanResultEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      scanType: scanType ?? this.scanType,
      riskLevel: riskLevel ?? this.riskLevel,
      confidence: confidence ?? this.confidence,
      category: category ?? this.category,
      matchedRules: matchedRules ?? this.matchedRules,
      offlineReason: offlineReason ?? this.offlineReason,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      aiSimpleExplanation: aiSimpleExplanation ?? this.aiSimpleExplanation,
      aiReason: aiReason ?? this.aiReason,
      aiRecommendedAction: aiRecommendedAction ?? this.aiRecommendedAction,
      aiShortSummary: aiShortSummary ?? this.aiShortSummary,
      timestamp: timestamp ?? this.timestamp,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
    );
  }
}
