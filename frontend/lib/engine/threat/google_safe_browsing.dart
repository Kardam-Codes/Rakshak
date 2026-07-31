import 'dart:math';
import 'threat_models.dart';

class GoogleSafeBrowsing implements ThreatProvider {
  @override
  Future<ThreatResult> analyze(String url) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Mock backend behavior
    bool isMalicious = url.contains('malicious') || url.contains('phishing') || url == 'f691861f78f1fcbd5072104051080d5d9f39c70988dadf5a8545a606e8072198' || url == '67408f749d9e5d5c3a239d63566bb65ee0aa88d1e7261eeb94beac3d1ee20fee';
    
    return ThreatResult(
      provider: 'Google Safe Browsing',
      status: isMalicious ? ThreatStatus.malicious : ThreatStatus.clean,
      confidence: isMalicious ? 95 : 99,
      reason: isMalicious ? 'Social Engineering (Phishing) Detected' : 'No threats detected',
      responseTimeMs: 200 + Random().nextInt(50),
    );
  }
}
