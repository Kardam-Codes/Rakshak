import '../engine/models/risk_level.dart';
import '../engine/models/scam_category.dart';

class CallEntity {
  final int? id;
  final String phoneNumber;
  final String? contactName;
  final String callType; // "incoming", "outgoing", "missed", "rejected"
  final DateTime timestamp;
  final int durationSeconds;
  final bool isKnownContact;
  
  // Analysis Fields
  final RiskLevel riskLevel;
  final ScamCategory category;
  final List<String> matchedRules;
  final String offlineReason;
  
  // AI Metrics
  final String? aiExplanation;
  final String? aiRecommendedAction;

  CallEntity({
    this.id,
    required this.phoneNumber,
    this.contactName,
    required this.callType,
    required this.timestamp,
    required this.durationSeconds,
    this.isKnownContact = false,
    this.riskLevel = RiskLevel.safe,
    this.category = ScamCategory.unknown,
    this.matchedRules = const [],
    this.offlineReason = '',
    this.aiExplanation,
    this.aiRecommendedAction,
  });

  CallEntity copyWith({
    int? id,
    String? phoneNumber,
    String? contactName,
    String? callType,
    DateTime? timestamp,
    int? durationSeconds,
    bool? isKnownContact,
    RiskLevel? riskLevel,
    ScamCategory? category,
    List<String>? matchedRules,
    String? offlineReason,
    String? aiExplanation,
    String? aiRecommendedAction,
  }) {
    return CallEntity(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      contactName: contactName ?? this.contactName,
      callType: callType ?? this.callType,
      timestamp: timestamp ?? this.timestamp,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isKnownContact: isKnownContact ?? this.isKnownContact,
      riskLevel: riskLevel ?? this.riskLevel,
      category: category ?? this.category,
      matchedRules: matchedRules ?? this.matchedRules,
      offlineReason: offlineReason ?? this.offlineReason,
      aiExplanation: aiExplanation ?? this.aiExplanation,
      aiRecommendedAction: aiRecommendedAction ?? this.aiRecommendedAction,
    );
  }
}
