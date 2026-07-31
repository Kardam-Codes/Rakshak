import '../../models/scan_entity.dart';
import 'validator.dart';

class DomainChecker implements Validator {
  static const List<String> validTlds = [
    'com', 'org', 'net', 'edu', 'gov', 'mil', 'int',
    'in', 'us', 'uk', 'ca', 'au', 'eu', 'co', 'io', 'ai',
    // add more standard ones, but reject unknown weird ones
  ];

  static const List<String> suspiciousTlds = [
    'top', 'xyz', 'club', 'info', 'work', 'click', 'site', 'online', 'vip', 'icu', 'tk', 'ml', 'ga', 'cf', 'gq'
  ];

  static const List<String> knownShorteners = [
    'bit.ly', 'tinyurl.com', 'is.gd', 'cutt.ly', 'rb.gy', 't.co', 'shorturl.at', 'ow.ly', 'rebrand.ly'
  ];

  @override
  ValidationResult validate(String input, ScanType type) {
    Uri? uri;
    try {
      uri = Uri.parse(input);
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        return ValidationResult.valid();
      }
    } catch (_) {
      return ValidationResult.valid(); // handled by url validator
    }

    if (uri.host.isEmpty) return ValidationResult.valid();

    // Check direct IP (again, handled mostly in URL validator, but in case)
    final ipRegex = RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$');
    if (ipRegex.hasMatch(uri.host)) {
       return ValidationResult.invalid('Direct IP address usage.', 'Direct IP addresses are unverifiable.');
    }

    final parts = uri.host.split('.');
    if (parts.length < 2) {
      // Localhost or malformed
      return ValidationResult.invalid('Malformed domain structure.', 'Domain must have a valid structure.');
    }

    final tld = parts.last.toLowerCase();

    // Unknown TLD check
    if (!validTlds.contains(tld) && !suspiciousTlds.contains(tld)) {
      return ValidationResult.invalid('Unknown or invalid top-level domain (.$tld).', 'Domain could not be verified.');
    }

    // Shorteners
    for (var shortener in knownShorteners) {
      if (uri.host.toLowerCase().contains(shortener)) {
        return ValidationResult.invalid('URL shortener detected.', 'Cannot verify the final destination of shortened links.');
      }
    }

    return ValidationResult.valid();
  }
}
