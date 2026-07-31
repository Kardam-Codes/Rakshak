import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import '../models/detection_result.dart';
import '../models/risk_level.dart';
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
    // 1. Layer 1: Zero-Knowledge Short-Circuit
    if (offlineResult.riskLevel == RiskLevel.critical) {
      // Threat is already categorized maliciously offline. 
      // Abort external APIs to preserve absolute privacy.
      return DecisionMerger.merge(offlineResult, null);
    }
    
    // Layer 2: Zero-Knowledge Hashes
    // Never transmit plaintext URLs to the cloud.
    final bytes = utf8.encode(url);
    final hashedUrl = crypto.sha256.convert(bytes).toString();
    // 2. Check Cache
    final cachedSummary = _cache.get(hashedUrl);
    if (cachedSummary != null) {
      return DecisionMerger.merge(offlineResult, cachedSummary);
    }

    // 3. Check Internet Connectivity
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      return DecisionMerger.merge(offlineResult, null);
    }

    // 4. Query Threat Api using the Hash (Masking PII)
    try {
      final summary = await _api.scanUrl(hashedUrl).timeout(const Duration(seconds: 5));
      _cache.put(hashedUrl, summary);
      return DecisionMerger.merge(offlineResult, summary);
    } catch (_) {
      // Timeout or API failure
      return DecisionMerger.merge(offlineResult, null);
    }
  }
}
