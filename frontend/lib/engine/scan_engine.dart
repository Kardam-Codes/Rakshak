import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/scan_entity.dart';
import 'models/risk_level.dart';
import 'scan_classifier.dart';
import 'threat/threat_service.dart';
import 'threat/threat_models.dart';
import 'evidence/evidence_models.dart';
import 'evidence/evidence_builder.dart';
import 'evidence/confidence_engine.dart';
import '../repositories/scan_repository.dart';
import '../services/scan_analytics_service.dart';

class ScanEngine {
  final ScanRepository _scanRepository;
  final ScanAnalyticsService _analyticsService;
  final String backendBaseUrl;

  ScanEngine({
    required ScanRepository scanRepository,
    required ScanAnalyticsService analyticsService,
    this.backendBaseUrl = 'http://10.0.2.2:8000',
  })  : _scanRepository = scanRepository,
        _analyticsService = analyticsService;

  Future<ScanResultEntity> processScan({
    required String rawContent,
    required ScanType scanType,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    final normalizedContent = normalizeInput(rawContent, scanType);

    // 1. Cache Lookup
    final cached = await _scanRepository.findCachedScan(normalizedContent);
    if (cached != null) {
      stopwatch.stop();
      _analyticsService.trackScan(
        scanType: scanType.name,
        riskLevel: cached.riskLevel.name,
        durationMs: stopwatch.elapsedMilliseconds,
      );
      return cached;
    }

    // 2. Validation & Offline Rule Analysis via Classifier
    final detection = ScanClassifier.classify(normalizedContent, scanType);

    // 2.5 Threat Intelligence Layer & Decision Merger
    final threatService = ThreatService();
    MergedDecision mergedDecision;
    if (scanType == ScanType.url) {
      mergedDecision = await threatService.analyzeAndMerge(normalizedContent, detection);
    } else {
      // For non-URLs (like plain text or local images), we might skip threat intel or just pass null.
      // Assuming threat service is designed for URLs based on the prompt.
      mergedDecision = await threatService.analyzeAndMerge(normalizedContent, detection);
    }

    // 2.7. Normalize Evidence & Calculate Confidence
    final evidence = EvidenceBuilder.buildEvidence(
      structuredEvidence: mergedDecision.structuredEvidence,
      riskLevel: mergedDecision.riskLevel,
    );
    final confidenceScore = ConfidenceEngine.calculateConfidence(
      evidence,
      mergedDecision.usedThreatIntelligence,
    );

    String? aiSimpleExplanation;
    String? aiReason;
    String? aiRecommendedAction;
    String? aiShortSummary;

    // 3. Gemini Explainability (Triggered ONLY for Medium, High, Critical)
    final bool requiresAiExplanation = mergedDecision.riskLevel == RiskLevel.medium ||
        mergedDecision.riskLevel == RiskLevel.high ||
        mergedDecision.riskLevel == RiskLevel.critical;

    if (requiresAiExplanation) {
      try {
        final response = await http
            .post(
              Uri.parse('$backendBaseUrl/explain_scan'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'content': normalizedContent,
                'scan_type': scanType.name,
                'category': detection.category.name,
                'risk': mergedDecision.riskLevel.name,
                'confidence': detection.confidence,
                'evidence': mergedDecision.structuredEvidence,
              }),
            )
            .timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          aiSimpleExplanation = data['simple_explanation'];
          aiReason = data['reason'];
          aiRecommendedAction = data['recommended_action'];
          aiShortSummary = data['short_summary'];
        }
      } catch (_) {
        // Safe offline fallback when backend unreachable
        aiSimpleExplanation = 'Based on available analysis, this content was evaluated locally.';
        aiReason = detection.reason;
        aiRecommendedAction = detection.recommendedAction;
        aiShortSummary = detection.riskLevel == RiskLevel.safe ? 'Appears Safe' : 'Risk Detected';
      }
    } else {
      // Safe fallback for safe / low risk
      aiSimpleExplanation = detection.riskLevel == RiskLevel.safe 
        ? 'Verified content passed all local security checks.' 
        : 'Based on available analysis, no immediate high-risk patterns were detected.';
      aiReason = detection.reason;
      aiRecommendedAction = detection.recommendedAction;
      aiShortSummary = detection.riskLevel == RiskLevel.safe ? 'Appears Safe' : 'Suspicious';
    }

    stopwatch.stop();
    final elapsedMs = stopwatch.elapsedMilliseconds;

    final entity = ScanResultEntity(
      content: normalizedContent,
      scanType: scanType,
      riskLevel: mergedDecision.riskLevel,
      confidence: detection.confidence,
      category: detection.category,
      matchedRules: detection.matchedRules,
      offlineReason: detection.reason,
      recommendedAction: detection.recommendedAction,
      aiSimpleExplanation: aiSimpleExplanation,
      aiReason: aiReason,
      aiRecommendedAction: aiRecommendedAction,
      aiShortSummary: aiShortSummary,
      evidence: evidence,
      confidencePercentage: confidenceScore.percentage,
      timestamp: DateTime.now(),
      processingTimeMs: elapsedMs,
    );

    // Save result to Hive persistence
    final savedId = await _scanRepository.saveScan(entity);
    final finalEntity = entity.copyWith(id: savedId);

    // Track analytics locally
    _analyticsService.trackScan(
      scanType: scanType.name,
      riskLevel: mergedDecision.riskLevel.name,
      durationMs: elapsedMs,
    );

    return finalEntity;
  }

  String normalizeInput(String rawContent, ScanType type) {
    String trimmed = rawContent.trim();
    if (type == ScanType.url) {
      if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
        trimmed = 'https://$trimmed';
      }
    }
    return trimmed;
  }
}
