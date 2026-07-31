import '../../models/scan_entity.dart';

class ValidationResult {
  final bool isValid;
  final String? reason;
  final String? recommendedAction;

  ValidationResult({
    required this.isValid,
    this.reason,
    this.recommendedAction,
  });

  factory ValidationResult.valid() {
    return ValidationResult(isValid: true);
  }

  factory ValidationResult.invalid(String reason, String recommendedAction) {
    return ValidationResult(
      isValid: false,
      reason: reason,
      recommendedAction: recommendedAction,
    );
  }
}

abstract class Validator {
  ValidationResult validate(String input, ScanType type);
}
