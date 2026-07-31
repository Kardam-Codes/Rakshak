import 'dart:io';
import '../models/detection_result.dart';
import 'decision_merger.dart';
import 'threat_cache.dart';
import 'threat_models.dart';
import 'google_safe_browsing.dart';
import 'virus_total.dart';
import 'phishtank.dart';
import 'openphish.dart';

abstract class ThreatApi {
  Future<ThreatSummary> scanUrl(String url);
}

class MockThreatApi implements ThreatApi {
  final List<ThreatProvider> _providers = [
    GoogleSafeBrowsing(),
    VirusTotal(),
    PhishTank(),
    OpenPhish(),
  ];

  @override
  Future<ThreatSummary> scanUrl(String url) async {
    final futures = _providers.map((provider) => provider.analyze(url));
    final results = await Future.wait(futures);
    
    return ThreatSummary(
      results: results,
      timestamp: DateTime.now(),
    );
  }
}

class ThreatService {
  final ThreatApi _api;
  final ThreatCache _cache = ThreatCache();

  ThreatService({ThreatApi? api}) : _api = api ?? MockThreatApi();

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<MergedDecision> analyzeAndMerge(String url, DetectionResult offlineResult) async {
    // 1. Check if offline is already Critical based on Validation Failure
    // But we still want to query threat intel for AI explainability if possible
    
    // 2. Check Cache
    final cachedSummary = _cache.get(url);
    if (cachedSummary != null) {
      return DecisionMerger.merge(offlineResult, cachedSummary);
    }

    // 3. Check Internet Connectivity
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      return DecisionMerger.merge(offlineResult, null);
    }

    // 4. Query Threat Api (Backend Mock)
    try {
      final summary = await _api.scanUrl(url).timeout(const Duration(seconds: 5));
      _cache.put(url, summary);
      return DecisionMerger.merge(offlineResult, summary);
    } catch (_) {
      // Timeout or API failure
      return DecisionMerger.merge(offlineResult, null);
    }
  }
}
