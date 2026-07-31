import '../engine/models/risk_level.dart';

class FamilyAlertHistoryEntity {
  final int? id;
  final String recipientPhone;
  final String recipientName;
  final RiskLevel riskLevel;
  final String category;
  final String messageSummary;
  final DateTime timestamp;
  final String deliveryStatus; // "sent", "failed", "cancelled"
  final bool viewed;

  FamilyAlertHistoryEntity({
    this.id,
    required this.recipientPhone,
    required this.recipientName,
    required this.riskLevel,
    required this.category,
    required this.messageSummary,
    required this.timestamp,
    required this.deliveryStatus,
    this.viewed = false,
  });

  FamilyAlertHistoryEntity copyWith({
    int? id,
    String? recipientPhone,
    String? recipientName,
    RiskLevel? riskLevel,
    String? category,
    String? messageSummary,
    DateTime? timestamp,
    String? deliveryStatus,
    bool? viewed,
  }) {
    return FamilyAlertHistoryEntity(
      id: id ?? this.id,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      recipientName: recipientName ?? this.recipientName,
      riskLevel: riskLevel ?? this.riskLevel,
      category: category ?? this.category,
      messageSummary: messageSummary ?? this.messageSummary,
      timestamp: timestamp ?? this.timestamp,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      viewed: viewed ?? this.viewed,
    );
  }
}
