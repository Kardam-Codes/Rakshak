import '../../models/scan_entity.dart';
import 'validator.dart';

class UpiValidator implements Validator {
  @override
  ValidationResult validate(String input, ScanType type) {
    if (!input.toLowerCase().startsWith('upi://pay')) {
      return ValidationResult.valid(); // not a upi link, skip validation
    }

    Uri? uri;
    try {
      uri = Uri.parse(input);
    } catch (_) {
      return ValidationResult.invalid('Malformed UPI string.', 'Ensure the UPI request is correctly formatted.');
    }

    final pa = uri.queryParameters['pa']; // Payee Address
    
    if (pa == null || pa.isEmpty) {
      return ValidationResult.invalid('Missing Payee Address (UPI ID).', 'UPI request must specify a valid recipient.');
    }

    if (!pa.contains('@')) {
      return ValidationResult.invalid('Invalid UPI ID format.', 'UPI ID is incorrectly formatted.');
    }

    // Check for fake merchant structure
    final handle = pa.split('@').last.toLowerCase();
    final suspiciousHandles = ['upi', 'admin', 'refund', 'support', 'help'];
    if (suspiciousHandles.contains(handle) || pa.toLowerCase().contains('refund')) {
      return ValidationResult.invalid('Suspicious UPI recipient structure.', 'Recipient ID mimics system keywords.');
    }

    return ValidationResult.valid();
  }
}
