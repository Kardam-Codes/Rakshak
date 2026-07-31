import 'dart:math';
import 'threat_models.dart';

class PhishTank implements ThreatProvider {
  @override
  Future<ThreatResult> analyze(String url) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    bool isPhishing = url.contains('phish');
    
    return ThreatResult(
      provider: 'PhishTank',
      status: isPhishing ? ThreatStatus.malicious : ThreatStatus.not_found,
      confidence: isPhishing ? 90 : 0,
      reason: isPhishing ? 'Verified phishing URL in database' : 'Not found in database',
      responseTimeMs: 150 + Random().nextInt(50),
    );
  }
}
