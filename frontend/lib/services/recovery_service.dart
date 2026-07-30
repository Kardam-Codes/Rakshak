import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class RecoveryService {
  
  static const String _rbiHelpline = '14440';
  static const String _cyberCrimeUrl = 'https://cybercrime.gov.in';

  /// Contact the bank using the RBI helpline
  Future<bool> contactBank() async {
    final Uri telUri = Uri(scheme: 'tel', path: _rbiHelpline);
    if (await canLaunchUrl(telUri)) {
      return await launchUrl(telUri);
    }
    return false;
  }

  /// Report to Cyber Crime website
  Future<bool> reportCyberCrime() async {
    final Uri url = Uri.parse(_cyberCrimeUrl);
    if (await canLaunchUrl(url)) {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Redirect to dialer for manual block
  Future<bool> blockNumber(String number) async {
    // Show instructions on UI and then open dialer
    final Uri telUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(telUri)) {
      return await launchUrl(telUri);
    }
    return false;
  }

  /// Send SMS to trusted contact
  Future<bool> notifyTrustedContact(String contactNumber, String originalMessage) async {
    final String body = 'Hello, I received this unusual msg:\n\n$originalMessage';
    final Uri smsUri = Uri(scheme: 'sms', path: contactNumber, queryParameters: {'body': body});
    if (await canLaunchUrl(smsUri)) {
      return await launchUrl(smsUri);
    }
    return false;
  }

  /// Save evidence to a dedicated local Hive box
  Future<bool> saveEvidence(String evidenceDetails, String type) async {
    try {
      if (!Hive.isBoxOpen('evidence_box')) {
        await Hive.openBox('evidence_box');
      }
      final box = Hive.box('evidence_box');
      await box.add({
        'type': type,
        'details': evidenceDetails,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Error saving evidence: $e');
      return false;
    }
  }
}
