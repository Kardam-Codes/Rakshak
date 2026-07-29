import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/scan_entity.dart';
import 'models/risk_level.dart';
import 'rule_engine.dart';
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

    // 2. Offline Rule Analysis
    final detection = RuleEngine.analyzeScan(normalizedContent, scanType);

    String? aiSimpleExplanation;
    String? aiReason;
    String? aiRecommendedAction;
    String? aiShortSummary;

    // 3. Gemini Explainability (Triggered ONLY for Medium, High, Critical)
    final bool requiresAiExplanation = detection.riskLevel == RiskLevel.medium ||
        detection.riskLevel == RiskLevel.high ||
        detection.riskLevel == RiskLevel.critical;

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
                'risk': detection.riskLevel.name,
                'confidence': detection.confidence,
                'matched_rules': detection.matchedRules,
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
        aiSimpleExplanation = 'Based on available analysis, this content matches local risk patterns.';
        aiReason = detection.reason;
        aiRecommendedAction = detection.recommendedAction;
        aiShortSummary = 'Risk Detected';
      }
    } else {
      // Safe fallback for safe / low risk
      aiSimpleExplanation = 'Based on available analysis, no immediate high-risk patterns were detected.';
      aiReason = 'The scanned item passed local rule checks with safe parameters.';
      aiRecommendedAction = 'Exercise normal caution when proceeding.';
      aiShortSummary = 'Appears Safe';
    }

    stopwatch.stop();
    final elapsedMs = stopwatch.elapsedMilliseconds;

    final entity = ScanResultEntity(
      content: normalizedContent,
      scanType: scanType,
      riskLevel: detection.riskLevel,
      confidence: detection.confidence,
      category: detection.category,
      matchedRules: detection.matchedRules,
      offlineReason: detection.reason,
      recommendedAction: detection.recommendedAction,
      aiSimpleExplanation: aiSimpleExplanation,
      aiReason: aiReason,
      aiRecommendedAction: aiRecommendedAction,
      aiShortSummary: aiShortSummary,
      timestamp: DateTime.now(),
      processingTimeMs: elapsedMs,
    );

    // Save result to Hive persistence
    final savedId = await _scanRepository.saveScan(entity);
    final finalEntity = entity.copyWith(id: savedId);

    // Track analytics locally
    _analyticsService.trackScan(
      scanType: scanType.name,
      riskLevel: detection.riskLevel.name,
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
