import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/engine/models/detection_result.dart';
import 'package:rakshak/engine/models/risk_level.dart';
import 'package:rakshak/engine/models/scam_category.dart';
import 'package:rakshak/engine/threat/threat_cache.dart';
import 'package:rakshak/engine/threat/threat_models.dart';
import 'package:rakshak/engine/threat/threat_service.dart';

class MockSlowApi implements ThreatApi {
  @override
  Future<ThreatSummary> scanUrl(String url) async {
    await Future.delayed(const Duration(seconds: 10));
    return ThreatSummary(results: [], timestamp: DateTime.now());
  }
}

class MockErrorApi implements ThreatApi {
  @override
  Future<ThreatSummary> scanUrl(String url) async {
    throw Exception('API failed');
  }
}

void main() {
  group('ThreatService Cache and Resilience', () {
    setUp(() {
      ThreatCache().clear();
    });

    DetectionResult createResult() {
      return DetectionResult(
        riskLevel: RiskLevel.safe,
        confidence: 0.9,
        category: ScamCategory.unknown,
        matchedRules: [],
        reason: 'Valid URL.',
        recommendedAction: '',
        timestamp: DateTime.now(),
      );
    }

    test('Caches responses correctly', () async {
      final service = ThreatService(); // Uses MockThreatApi internally
      final result1 = await service.analyzeAndMerge('https://example.com', createResult());
      
      expect(result1.usedThreatIntelligence, true);
      
      final cached = ThreatCache().get('https://example.com');
      expect(cached, isNotNull);
      
      // Should hit cache immediately
      final result2 = await service.analyzeAndMerge('https://example.com', createResult());
      expect(result2.usedThreatIntelligence, true);
    });

    test('Handles provider timeout', () async {
      final service = ThreatService(api: MockSlowApi());
      // Should timeout after 5 seconds and return offline rules
      final result = await service.analyzeAndMerge('https://example.com', createResult());
      
      expect(result.usedThreatIntelligence, false);
      expect(result.structuredEvidence['threatIntelligence']?.first, contains('Online verification unavailable'));
    });

    test('Handles provider errors', () async {
      final service = ThreatService(api: MockErrorApi());
      final result = await service.analyzeAndMerge('https://example.com', createResult());
      
      expect(result.usedThreatIntelligence, false);
    });
  });
}
