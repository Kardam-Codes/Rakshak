import 'dart:math';
import 'threat_models.dart';

class GoogleSafeBrowsing implements ThreatProvider {
  @override
  Future<ThreatResult> analyze(String url) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Mock backend behavior
    bool isMalicious = url.contains('malicious') || url.contains('phishing');
    
    return ThreatResult(
      provider: 'Google Safe Browsing',
      status: isMalicious ? ThreatStatus.malicious : ThreatStatus.clean,
      confidence: isMalicious ? 95 : 99,
      reason: isMalicious ? 'Social Engineering (Phishing) Detected' : 'No threats detected',
      responseTimeMs: 200 + Random().nextInt(50),
    );
  }
}
