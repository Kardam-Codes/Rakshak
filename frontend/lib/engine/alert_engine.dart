import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_entity.dart';
import 'models/risk_level.dart';
import '../api/rakshak_client.dart';
import '../utils/pii_masking.dart';
import '../repositories/notification_repository.dart';
import '../models/call_entity.dart';
import '../repositories/call_repository.dart';

class AlertEngine {
  final NotificationRepository _repository;
  final CallRepository _callRepository;
  // A callback triggered to show native popup
  final Function(NotificationEntity)? onCriticalAlert;

  AlertEngine(this._repository, this._callRepository, {this.onCriticalAlert});

  Future<void> processNotification(NotificationEntity entity) async {
    // 1. Generate hash for deduplication/caching based on content
    final rawString = '${entity.appName}_${entity.title}_${entity.body}';
    final contentHash = sha256.convert(utf8.encode(rawString)).toString();

    // Attach hash
    var currentEntity = entity.copyWith(notificationHash: contentHash);

    // 2. Fast Path: If Safe/Low, just save and exit to avoid AI overhead
    if (currentEntity.riskLevel == RiskLevel.safe || currentEntity.riskLevel == RiskLevel.low) {
      await _repository.saveNotification(currentEntity);
      return;
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
      if (entity.riskLevel == RiskLevel.high || entity.riskLevel == RiskLevel.critical) {
        onCriticalAlert!(entity);
      }
    }
  }

  Future<void> _processAiAsync(NotificationEntity entity, String hash) async {
    try {
      // Mask Sensitive PII (OTP, PINs, Cards) BEFORE sending outbound to REST layer
      final maskedTitle = PIIMasking.maskData(entity.title);
      final maskedBody = PIIMasking.maskData(entity.body);
      final fullMaskedText = 'Title: $maskedTitle\nBody: $maskedBody';

      // Call API
      final explanation = await RakshakClient.fetchExplanation(
        notificationText: fullMaskedText,
        category: entity.category,
        risk: entity.riskLevel,
        confidence: 0.8, // Fallback base, offline engine output normally bound here
        matchedRules: entity.matchedRules,
      );

      if (explanation != null) {
         final updatedEntity = entity.copyWith(
            aiSimpleExplanation: explanation.simpleExplanation,
            aiReason: explanation.reason,
            aiRecommendedAction: explanation.recommendedAction,
         );
         // Update the existing record in Hive dynamically triggering Riverpod update
         await _repository.updateNotification(updatedEntity);
      }
    } catch (e) {
      debugPrint('AI Processing Failed: $e');
    }
  }

  Future<void> processCall(CallEntity entity) async {
    // 1. Fast Path
    if (entity.riskLevel == RiskLevel.safe || entity.riskLevel == RiskLevel.low) {
      await _callRepository.saveCall(entity);
      return;
    }

    // 2. Save immediately for UI
    final savedId = await _callRepository.saveCall(entity);
    final currentEntity = entity.copyWith(id: savedId);

    // 3. Trigger Async processing
    _processCallAiAsync(currentEntity);
  }

  Future<void> _processCallAiAsync(CallEntity entity) async {
    try {
      final explanation = await RakshakClient.fetchCallExplanation(
        phoneNumber: entity.phoneNumber, // We can PII mask this if backend rules are strict
        category: entity.category,
        risk: entity.riskLevel,
        confidence: 0.8,
        matchedRules: entity.matchedRules,
        callDuration: entity.durationSeconds,
      );

      if (explanation != null) {
         final updatedEntity = entity.copyWith(
            aiExplanation: "${explanation.simpleExplanation} ${explanation.reason}",
            aiRecommendedAction: explanation.recommendedAction,
         );
         await _callRepository.updateCall(updatedEntity);
      }
    } catch (e) {
      debugPrint('Call AI Processing Failed: $e');
    }
  }
}
