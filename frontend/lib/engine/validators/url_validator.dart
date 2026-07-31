import '../../models/scan_entity.dart';
import 'validator.dart';

class UrlValidator implements Validator {
  @override
  ValidationResult validate(String input, ScanType type) {
    if (type != ScanType.url) {
      return ValidationResult.valid();
    }
    if (input.isEmpty) {
      return ValidationResult.invalid('URL is empty.', 'Please provide a valid URL.');
    }

    Uri? uri;
    try {
      uri = Uri.parse(input);
    } catch (e) {
      return ValidationResult.invalid('Malformed URL syntax.', 'Ensure the URL is correctly formatted.');
    }

    if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return ValidationResult.invalid('Unsupported protocol scheme.', 'Only http and https protocols are supported.');
    }

    if (uri.host.isEmpty) {
      return ValidationResult.invalid('Missing hostname.', 'The URL must contain a valid hostname.');
    }

    if (uri.host.toLowerCase() == 'localhost' || uri.host.startsWith('127.')) {
      return ValidationResult.invalid('Localhost or loopback address detected.', 'Local addresses are not allowed.');
    }

    // Direct IP URL check
    final ipRegex = RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$');
    if (ipRegex.hasMatch(uri.host)) {
      // It is often considered suspicious in a phishing context
      return ValidationResult.invalid('Direct IP address usage.', 'Legitimate services typically use registered domains, not direct IP addresses.');
    }

    // Executable downloads
    if (uri.path.toLowerCase().endsWith('.apk') || uri.path.toLowerCase().endsWith('.exe')) {
      return ValidationResult.invalid('Executable file download detected.', 'Downloading executables from untrusted sources is dangerous.');
    }

    return ValidationResult.valid();
  }
}
