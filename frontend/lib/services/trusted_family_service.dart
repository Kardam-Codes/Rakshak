import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:telephony/telephony.dart';
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
  
  static final Map<String, DateTime> _recentlySentAlerts = {};

  TrustedFamilyService({
    required TrustedFamilyRepository repository,
    required AppDatabase db,
    required TrustedFamilyAnalyticsService analyticsService,
    this.backendBaseUrl = 'http://192.168.29.225:8000',
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
    
    // Prevent spamming family contacts by debouncing identical alerts for 30 minutes
    if (_recentlySentAlerts.containsKey(category)) {
      final lastSent = _recentlySentAlerts[category]!;
      if (DateTime.now().difference(lastSent).inMinutes < 30) {
        debugPrint('Blocked spam SMS for $category: Already sent recently.');
        return false;
      }
    }
    _recentlySentAlerts[category] = DateTime.now();

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

                'recipient_phone': contact.phoneNumber,
                'recipient_name': contact.name,
                'risk_level': riskLevel.name.toUpperCase(),
                'category': category,
                'reason': reason,
                'ai_explanation': aiExplanation,
                'recommended_action': recommendedAction,
                'notification_method': 'SMS_AND_WHATSAPP',
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
          recipientPhone: contact.phoneNumber,
          recipientName: contact.name,
          riskLevel: riskLevel,
          category: category,
          messageSummary: 'High-risk WhatsApp alert sent to ${contact.name} (${contact.relationship})',
          timestamp: DateTime.now(),
          deliveryStatus: isSuccess ? 'sent' : 'failed',
          viewed: false,
        );

        await _db.insertFamilyAlertHistory(historyEntity);
      } catch (e) {
        // Fallback history record if network offline (Execute Telephony SMS)
        if (e is SocketException || e.toString().contains('TimeoutException')) {
          _analyticsService.logEvent('offline_sms_fallback_triggered');
          try {
             String smsBody = 'URGENT: $userName is targeted by a ${riskLevel.name} $category.\nReason: $reason.\nTake immediate action.';
             await Telephony.backgroundInstance.sendSms(to: contact.phoneNumber, message: smsBody);
          } catch(smsErr) {
             debugPrint('SMS Fallback failed: $smsErr');
          }
        }

        final historyEntity = FamilyAlertHistoryEntity(
          recipientPhone: contact.phoneNumber,
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
