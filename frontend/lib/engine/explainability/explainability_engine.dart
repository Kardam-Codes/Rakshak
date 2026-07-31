import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../models/explanation_entity.dart';
import '../../engine/models/risk_level.dart';
import '../../engine/models/scam_category.dart';
import '../../repositories/explainability_repository.dart';
import '../../api/rakshak_client.dart';
import 'templates/explanation_templates.dart';
import 'prompt_builder.dart';

class ExplainabilityEngine {
  final ExplainabilityRepository _repository;

  ExplainabilityEngine(this._repository);

  String _generateHash(String sourceFeature, String content) {
    final rawString = '${sourceFeature}_$content';
    return sha256.convert(utf8.encode(rawString)).toString();
  }

  Future<ExplanationEntity> processExplanation({
    required String sourceFeature,
    required String content,
    required ScamCategory category,
    required RiskLevel riskLevel,
    required double confidence,
    required List<String> matchedRules,
  }) async {
    final hash = _generateHash(sourceFeature, content);

    // 1. Check Cache
    final cached = _repository.findExplanationByHash(hash);
    if (cached != null) {
      // Re-trigger async AI fetch if it was interrupted previously
      if (cached.aiExplanation == null && riskLevel != RiskLevel.safe) {
        _triggerAiFetch(cached, content);
      }
      return cached;
    }

    // 2. Build Offline Fallbacks
    final template = ExplanationTemplateBuilder.build(category);

    ExplanationEntity entity = ExplanationEntity(
      sourceFeature: sourceFeature,
      category: category.name,
      riskLevel: riskLevel,
      confidence: confidence,
      offlineExplanation: template['explanation'],
      recommendedAction: template['recommendation'],
      preventionTips: template['preventionTips'],
      summary: 'Processed by Offline RuleEngine',
      createdAt: DateTime.now(),
      contentHash: hash,
    );

    // 3. Persist Fallback Entity Immediately
    final id = await _repository.saveExplanation(entity);
    entity = entity.copyWith(id: id);

    // 4. Trigger Async AI Fetch if High/Critical
    if (riskLevel != RiskLevel.safe) {
      _triggerAiFetch(entity, content);
    }

    return entity;
  }

  Future<void> _triggerAiFetch(ExplanationEntity entity, String content) async {
    try {
      final prompt = PromptBuilder.buildCentralizedPrompt(
        contextType: entity.sourceFeature,
        content: content,
        category: entity.category,
        riskLevel: entity.riskLevel.name,
        confidence: entity.confidence,
        matchedRules: [], // We can pass real matched rules if cached
      );

      final explanationDto = await RakshakClient.fetchGeneralizedExplanation(prompt);
      
      if (explanationDto != null) {
        final updatedEntity = entity.copyWith(
          aiExplanation: explanationDto.reason,
          summary: explanationDto.simpleExplanation,
          recommendedAction: explanationDto.recommendedAction,
        );
        await _repository.updateExplanation(updatedEntity);
      }
    } catch (_) {
      // Fallback natively triggers if this fails.
    }
  }
}
