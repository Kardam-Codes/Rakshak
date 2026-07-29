import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/ai_explanation.dart';
import '../../engine/models/risk_level.dart';
import '../../engine/models/scam_category.dart';

class RakshakClient {
  static const String _baseUrl = 'http://192.168.1.6:8000'; // Default emulator route for localhost

  static Future<AiExplanation?> fetchExplanation({
    required String notificationText,
    required ScamCategory category,
    required RiskLevel risk,
    required double confidence,
    required List<String> matchedRules,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/explain'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'notification_text': notificationText,
          'category': category.name,
          'risk': risk.name,
          'confidence': confidence,
          'matched_rules': matchedRules,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return AiExplanation.fromJson(jsonDecode(response.body));
      }
      return null; // Fallback happens in engine
    } catch (e) {
      // Offline fallback activated on API connection fail/timeout
      return null;
    }
  }

  static Future<AiExplanation?> fetchCallExplanation({
    required String phoneNumber,
    required ScamCategory category,
    required RiskLevel risk,
    required double confidence,
    required List<String> matchedRules,
    required int callDuration,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/explain_call'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'category': category.name,
          'risk': risk.name,
          'confidence': confidence,
          'matched_rules': matchedRules,
          'call_duration': callDuration,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return AiExplanation.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
