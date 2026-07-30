import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/database/app_database.dart';
import '../models/trusted_contact.dart';
import '../models/family_alert_history.dart';
import '../engine/models/risk_level.dart';
import '../repositories/trusted_family_repository.dart';
import 'trusted_family_analytics_service.dart';

class TrustedFamilyService {
  final TrustedFamilyRepository _repository;
  final AppDatabase _db;
  final TrustedFamilyAnalyticsService _analyticsService;
  final String backendBaseUrl;

  TrustedFamilyService({
    required TrustedFamilyRepository repository,
    required AppDatabase db,
    required TrustedFamilyAnalyticsService analyticsService,
    this.backendBaseUrl = 'http://192.168.1.6:8000',
  })  : _repository = repository,
        _db = db,
        _analyticsService = analyticsService;

  Future<bool> sendEmergencyAlert({
    required String userName,
    required RiskLevel riskLevel,
    required String category,
    required String reason,
    String? aiExplanation,
    String? recommendedAction,
  }) async {
    if (!_repository.isFeatureEnabled || !_repository.hasPrivacyConsent) {
      return false;
    }

    final contacts = await _repository.getAllContacts();
    if (contacts.isEmpty) return false;

    _analyticsService.logEvent('alerts_sent');
    bool overallSuccess = false;

    for (var contact in contacts) {
      if (!contact.isEmergency) continue;

      try {
        final response = await http
            .post(
              Uri.parse('$backendBaseUrl/family/send-alert'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'user_name': userName,
                'recipient_email': contact.email,
                'recipient_name': contact.name,
                'risk_level': riskLevel.name.toUpperCase(),
                'category': category,
                'reason': reason,
                'ai_explanation': aiExplanation,
                'recommended_action': recommendedAction,
              }),
            )
            .timeout(const Duration(seconds: 5));

        final bool isSuccess = response.statusCode == 200;
        if (isSuccess) {
          overallSuccess = true;
          _analyticsService.logEvent('emails_sent');
          _analyticsService.logEvent('delivery_success');
        }

        // Save delivery record to Hive history
        final historyEntity = FamilyAlertHistoryEntity(
          recipientEmail: contact.email,
          recipientName: contact.name,
          riskLevel: riskLevel,
          category: category,
          messageSummary: 'High-risk alert notification sent to ${contact.name} (${contact.relationship})',
          timestamp: DateTime.now(),
          deliveryStatus: isSuccess ? 'sent' : 'failed',
          viewed: false,
        );

        await _db.insertFamilyAlertHistory(historyEntity);
      } catch (e) {
        // Fallback history record if network offline
        final historyEntity = FamilyAlertHistoryEntity(
          recipientEmail: contact.email,
          recipientName: contact.name,
          riskLevel: riskLevel,
          category: category,
          messageSummary: 'Alert logged offline (backend unreachable)',
          timestamp: DateTime.now(),
          deliveryStatus: 'failed',
          viewed: false,
        );
        await _db.insertFamilyAlertHistory(historyEntity);
      }
    }

    return overallSuccess;
  }
}
