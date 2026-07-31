import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_entity.dart';
import '../models/call_entity.dart';
import 'models/risk_level.dart';
import 'models/scam_category.dart';
import '../api/rakshak_client.dart';
import '../utils/pii_masking.dart';
import '../repositories/notification_repository.dart';
import '../repositories/call_repository.dart';
import '../models/upi_transaction_entity.dart';
import '../repositories/upi_repository.dart';
import 'explainability/explainability_engine.dart';
import 'models/scam_category.dart';

class AlertEngine {
  final NotificationRepository _repository;
  final CallRepository _callRepository;
  final UPIRepository _upiRepository;
  final ExplainabilityEngine _explainEngine;
  // A callback triggered to show native popup
  final Function({required String title, required String category, required RiskLevel riskLevel})? onCriticalAlert;

  AlertEngine(this._repository, this._callRepository, this._upiRepository, this._explainEngine, {this.onCriticalAlert});

  Future<void> processNotification(NotificationEntity entity) async {
    // 1. Generate hash for deduplication/caching based on content
    final rawString = '${entity.appName}_${entity.title}_${entity.body}';
    final contentHash = sha256.convert(utf8.encode(rawString)).toString();

    // Attach hash
    var currentEntity = entity.copyWith(notificationHash: contentHash);
    final existingRecord = await _repository.findNotificationByHash(contentHash);
    if (existingRecord != null) {
      final updatedEntity = currentEntity.copyWith(
        id: existingRecord.id,
        isRead: existingRecord.isRead,
        aiSimpleExplanation: existingRecord.aiSimpleExplanation,
        aiReason: existingRecord.aiReason,
        aiRecommendedAction: existingRecord.aiRecommendedAction,
      );
      await _repository.updateNotification(updatedEntity);
      return;
    }

    // 2. Removed Fast Path: AI will be forced globally for all Notification variants
    if (currentEntity.riskLevel == RiskLevel.safe || currentEntity.riskLevel == RiskLevel.low) {
      currentEntity = currentEntity.copyWith(id: await _repository.saveNotification(currentEntity));
      // fall-through to AI fetch
    }

    // 3. Medium/High/Critical Path
    // First, check cache (has this exact content been AI processed before?)
    final cachedRecord = await _repository.findNotificationByHashWithAi(contentHash);
    
    if (cachedRecord != null && cachedRecord.aiSimpleExplanation != null) {
      // Re-use cached AI analysis
      currentEntity = currentEntity.copyWith(
        aiSimpleExplanation: cachedRecord.aiSimpleExplanation,
        aiReason: cachedRecord.aiReason,
        aiRecommendedAction: cachedRecord.aiRecommendedAction,
      );
      await _repository.saveNotification(currentEntity);
      _triggerPopupIfCritical(currentEntity);
      return;
    }

    // 4. Save entity immediately so UI can display it (offline result happens instantly)
    // AI fields remain null so UI can show "Analyzing..."
    final savedId = await _repository.saveNotification(currentEntity);
    currentEntity = currentEntity.copyWith(id: savedId);

    // 5. Trigger Popup immediately for critical/high before AI finishes
    _triggerPopupIfCritical(currentEntity);

    // 6. Asynchronous AI processing background wrapper
    _processAiAsync(currentEntity, contentHash);
  }

  void _triggerPopupIfCritical(NotificationEntity entity) {
    if (onCriticalAlert != null) {
      if (entity.riskLevel == RiskLevel.high || 
          entity.riskLevel == RiskLevel.critical ||
          entity.category == ScamCategory.otpScam) {
        onCriticalAlert!(
           title: entity.title,
           category: entity.category.name,
           riskLevel: entity.riskLevel,
        );
      }
    }
  }

  Future<void> _processAiAsync(NotificationEntity entity, String hash) async {
    try {
      // Mask Sensitive PII (OTP, PINs, Cards) BEFORE sending outbound to REST layer
      final maskedTitle = PIIMasking.maskData(entity.title);
      final maskedBody = PIIMasking.maskData(entity.body);
      final fullMaskedText = 'Title: $maskedTitle\nBody: $maskedBody';

      final expEntity = await _explainEngine.processExplanation(
        sourceFeature: 'notification',
        content: fullMaskedText,
        category: entity.category,
        riskLevel: entity.riskLevel,
        confidence: 0.8,
        matchedRules: entity.matchedRules,
      );

      final updatedEntity = entity.copyWith(
         aiSimpleExplanation: expEntity.summary,
         aiReason: expEntity.aiExplanation ?? expEntity.offlineExplanation,
         aiRecommendedAction: expEntity.recommendedAction,
      );
      // Update the existing record in Hive dynamically triggering Riverpod update
      await _repository.updateNotification(updatedEntity);
    } catch (e) {
      debugPrint('AI Processing Failed: $e');
    }
  }

  Future<void> processCall(CallEntity entity) async {
    // 1. Removed Fast Path bypass
    if (entity.riskLevel == RiskLevel.safe || entity.riskLevel == RiskLevel.low) {
       // fall-through
    }

    // 2. Save immediately for UI
    final savedId = await _callRepository.saveCall(entity);
    // 3. Trigger Async processing
    final currentEntity = entity.copyWith(id: savedId);
    
    if (currentEntity.riskLevel == RiskLevel.high || currentEntity.riskLevel == RiskLevel.critical) {
      if (onCriticalAlert != null) {
        onCriticalAlert!(
          title: 'Scam Call from ${currentEntity.phoneNumber}',
          category: currentEntity.category.name,
          riskLevel: currentEntity.riskLevel,
        );
      }
    }

    _processCallAiAsync(currentEntity);
  }

  Future<void> _processCallAiAsync(CallEntity entity) async {
    try {
      final expEntity = await _explainEngine.processExplanation(
        sourceFeature: 'call',
        content: 'Duration: ${entity.durationSeconds}s, Contact: ${entity.phoneNumber}',
        category: entity.category,
        riskLevel: entity.riskLevel,
        confidence: 0.8,
        matchedRules: entity.matchedRules,
      );

      final updatedEntity = entity.copyWith(
         aiExplanation: "${expEntity.summary} ${expEntity.aiExplanation ?? expEntity.offlineExplanation}",
         aiRecommendedAction: expEntity.recommendedAction,
      );
      await _callRepository.updateCall(updatedEntity);
    } catch (e) {
      debugPrint('Call AI Processing Failed: $e');
    }
  }

  Future<void> processUPITransaction(UPITransactionEntity entity) async {
    // fast path bypass removed
    if (entity.riskLevel == RiskLevel.safe || entity.riskLevel == RiskLevel.low) {
       // fall-through
    }

    if (entity.riskLevel == RiskLevel.high || entity.riskLevel == RiskLevel.critical) {
      if (onCriticalAlert != null) {
        onCriticalAlert!(
          title: 'UPI Payment to ${entity.merchantName}',
          category: entity.category.name,
          riskLevel: entity.riskLevel,
        );
      }
    }

    _processUpiAiAsync(entity);
  }

  Future<void> _processUpiAiAsync(UPITransactionEntity entity) async {
    try {
       // Masking UPI details
       final maskedMerchant = PIIMasking.maskData(entity.merchantName);
       
       final expEntity = await _explainEngine.processExplanation(
         sourceFeature: 'upi',
         content: 'Type: ${entity.transactionType.name}, Amount: ${entity.amount}, Merchant: $maskedMerchant',
         category: entity.category,
         riskLevel: entity.riskLevel,
         confidence: entity.confidence,
         matchedRules: entity.matchedRules,
       );

       if (entity.id != null) {
          await _upiRepository.updateTransactionExplanation(
              entity.id!,
              "${expEntity.summary} ${expEntity.aiExplanation ?? expEntity.offlineExplanation}",
              expEntity.recommendedAction
          );
       }
    } catch (e) {
       debugPrint('UPI AI Processing Failed: $e');
    }
  }
}
