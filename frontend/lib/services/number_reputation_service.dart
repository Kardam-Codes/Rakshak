import 'dart:math';

abstract class NumberReputationService {
  Future<double> getReputationScore(String phoneNumber);
  Future<bool> isKnownThreat(String phoneNumber);
}

class MockReputationService implements NumberReputationService {
  @override
  Future<double> getReputationScore(String phoneNumber) async {
    // Tightly couples a basic hashing logic for repeatable mocks
    // Score -> 0.0 (Extremely unsafe) to 1.0 (Extremely safe)
    
    // Hardcoded logic for testing:
    if (phoneNumber.startsWith('+1')) return 0.2; // foreign suspicious
    if (phoneNumber.startsWith('140')) return 0.1; // Known spam numbers in India
    
    return Random(phoneNumber.hashCode).nextDouble(); 
  }

  @override
  Future<bool> isKnownThreat(String phoneNumber) async {
    final score = await getReputationScore(phoneNumber);
    return score < 0.3;
  }
}
