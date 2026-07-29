import 'package:hive/hive.dart';
import '../../engine/models/risk_level.dart';

class ExplanationEntity extends HiveObject {
  int? id;
  String sourceFeature; // e.g., 'notification', 'call', 'upi'
  String category;
  RiskLevel riskLevel;
  double confidence;
  String offlineExplanation;
  String? aiExplanation;
  String? recommendedAction;
  List<String> preventionTips;
  String summary;
  DateTime createdAt;
  String contentHash;

  ExplanationEntity({
    this.id,
    required this.sourceFeature,
    required this.category,
    required this.riskLevel,
    required this.confidence,
    required this.offlineExplanation,
    this.aiExplanation,
    this.recommendedAction,
    required this.preventionTips,
    required this.summary,
    required this.createdAt,
    required this.contentHash,
  });

  ExplanationEntity copyWith({
    int? id,
    String? sourceFeature,
    String? category,
    RiskLevel? riskLevel,
    double? confidence,
    String? offlineExplanation,
    String? aiExplanation,
    String? recommendedAction,
    List<String>? preventionTips,
    String? summary,
    DateTime? createdAt,
    String? contentHash,
  }) {
    return ExplanationEntity(
      id: id ?? this.id,
      sourceFeature: sourceFeature ?? this.sourceFeature,
      category: category ?? this.category,
      riskLevel: riskLevel ?? this.riskLevel,
      confidence: confidence ?? this.confidence,
      offlineExplanation: offlineExplanation ?? this.offlineExplanation,
      aiExplanation: aiExplanation ?? this.aiExplanation,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      preventionTips: preventionTips ?? this.preventionTips,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
      contentHash: contentHash ?? this.contentHash,
    );
  }
}
