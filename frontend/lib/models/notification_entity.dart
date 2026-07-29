import '../engine/models/risk_level.dart';
import '../engine/models/scam_category.dart';

class NotificationEntity {
  final int? id;
  final String appName;
  final String packageName;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  
  // Offline Engine Metrics
  final RiskLevel riskLevel;
  final ScamCategory category;
  final List<String> matchedRules;
  final String reason;

  // AI Analysis (Phase 3)
  final String? aiSimpleExplanation;
  final String? aiReason;
  final String? aiRecommendedAction;
  final String? notificationHash;

  NotificationEntity({
    this.id,
    required this.appName,
    required this.packageName,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    this.riskLevel = RiskLevel.safe,
    this.category = ScamCategory.unknown,
    this.matchedRules = const [],
    this.reason = '',
    this.aiSimpleExplanation,
    this.aiReason,
    this.aiRecommendedAction,
    this.notificationHash,
  });

  NotificationEntity copyWith({
    int? id,
    String? appName,
    String? packageName,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    RiskLevel? riskLevel,
    ScamCategory? category,
    List<String>? matchedRules,
    String? reason,
    String? aiSimpleExplanation,
    String? aiReason,
    String? aiRecommendedAction,
    String? notificationHash,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      riskLevel: riskLevel ?? this.riskLevel,
      category: category ?? this.category,
      matchedRules: matchedRules ?? this.matchedRules,
      reason: reason ?? this.reason,
      aiSimpleExplanation: aiSimpleExplanation ?? this.aiSimpleExplanation,
      aiReason: aiReason ?? this.aiReason,
      aiRecommendedAction: aiRecommendedAction ?? this.aiRecommendedAction,
      notificationHash: notificationHash ?? this.notificationHash,
    );
  }
}
