import '../engine/models/risk_level.dart';
import '../engine/models/scam_category.dart';
import '../engine/models/transaction_type.dart';

class UPITransactionEntity {
  final int? id;
  final String appName;
  final String packageName;
  final String merchantName;
  final String upiId;
  final TransactionType transactionType;
  final double amount;
  final String currency;
  final DateTime timestamp;
  final RiskLevel riskLevel;
  final ScamCategory category;
  final List<String> matchedRules;
  final double confidence;
  final String offlineReason;
  final String? aiExplanation;
  final String? recommendedAction;
  final String status;

  UPITransactionEntity({
    this.id,
    required this.appName,
    required this.packageName,
    required this.merchantName,
    required this.upiId,
    required this.transactionType,
    required this.amount,
    this.currency = 'INR',
    required this.timestamp,
    required this.riskLevel,
    required this.category,
    required this.matchedRules,
    required this.confidence,
    required this.offlineReason,
    this.aiExplanation,
    this.recommendedAction,
    this.status = 'pending',
  });

  UPITransactionEntity copyWith({
    int? id,
    String? appName,
    String? packageName,
    String? merchantName,
    String? upiId,
    TransactionType? transactionType,
    double? amount,
    String? currency,
    DateTime? timestamp,
    RiskLevel? riskLevel,
    ScamCategory? category,
    List<String>? matchedRules,
    double? confidence,
    String? offlineReason,
    String? aiExplanation,
    String? recommendedAction,
    String? status,
  }) {
    return UPITransactionEntity(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      merchantName: merchantName ?? this.merchantName,
      upiId: upiId ?? this.upiId,
      transactionType: transactionType ?? this.transactionType,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      timestamp: timestamp ?? this.timestamp,
      riskLevel: riskLevel ?? this.riskLevel,
      category: category ?? this.category,
      matchedRules: matchedRules ?? this.matchedRules,
      confidence: confidence ?? this.confidence,
      offlineReason: offlineReason ?? this.offlineReason,
      aiExplanation: aiExplanation ?? this.aiExplanation,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      status: status ?? this.status,
    );
  }
}
