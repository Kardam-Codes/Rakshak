import 'dart:math';
import 'threat_models.dart';

class OpenPhish implements ThreatProvider {
  @override
  Future<ThreatResult> analyze(String url) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    bool isPhishing = url.contains('openphish');
    
    return ThreatResult(
      provider: 'OpenPhish',
      status: isPhishing ? ThreatStatus.malicious : ThreatStatus.not_found,
      confidence: isPhishing ? 95 : 0,
      reason: isPhishing ? 'Active phishing drop identified' : 'Not found',
      responseTimeMs: 100 + Random().nextInt(20),
    );
  }
}
