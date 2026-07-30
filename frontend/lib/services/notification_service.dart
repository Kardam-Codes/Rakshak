import 'dart:developer' as developer;
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../repositories/notification_repository.dart';
import '../models/notification_entity.dart';
import '../repositories/call_repository.dart';
import '../config/supported_apps.dart';
import '../engine/rule_engine.dart';
import '../engine/alert_engine.dart';
import '../services/upi_protection_service.dart';
import '../repositories/upi_repository.dart';
import '../engine/explainability/explainability_engine.dart';
import '../engine/models/scam_category.dart';

import '../repositories/call_repository.dart';
import 'package:flutter/material.dart';
import '../core/database/app_database.dart';
import '../routes/app_router.dart';
import '../screens/family/widgets/emergency_countdown_dialog.dart';
import 'trusted_family_service.dart';
import '../engine/models/risk_level.dart';

class NotificationService {
  final NotificationRepository _repository;
  final CallRepository _callRepository;
  final UPIRepository _upiRepository;
  final TrustedFamilyService _trustedFamilyService;
  final ExplainabilityEngine _explainEngine;
  late final UPIProtectionService _upiProtectionService;
  late final AlertEngine _alertEngine;

  NotificationService(this._repository, this._callRepository, this._upiRepository, this._trustedFamilyService, this._explainEngine) {
    _alertEngine = AlertEngine(_repository, _callRepository, _upiRepository, _explainEngine, onCriticalAlert: _showCriticalPopupNative);
    _upiProtectionService = UPIProtectionService(_upiRepository, _alertEngine);
  }

  void _showCriticalPopupNative({required String title, required String category, required RiskLevel riskLevel}) async {
    // 1. Always attempt to trigger the universal background overlay for OTPs specifically
    if (category == ScamCategory.otpScam.name) {
      if (await FlutterOverlayWindow.isPermissionGranted()) {
        await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          overlayTitle: "Rakshak OTP Security",
          overlayContent: "OTP: $title",
          flag: OverlayFlag.defaultFlag,
          visibility: NotificationVisibility.visibilityPublic,
        );
        // Share data payload for the generic overlay to decode
        FlutterOverlayWindow.shareData('OTP: $title');
      }
    }

    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => EmergencyCountdownDialog(
          userName: 'Rakshak User',
          category: category,
          riskLevel: riskLevel.name,
          onConfirm: () {
            _trustedFamilyService.sendEmergencyAlert(
               userName: 'Rakshak User',
               riskLevel: riskLevel,
               category: category,
               reason: title,
            ).then((success) {
               if (success && context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Emergency Alert Dispatched Successfully!'))
                   );
               }
            });
          },
          onCancel: () {},
        ),
      );
    }
  }

  Future<void> syncExistingNotifications() async {
    try {
      final notifications = await NotificationListenerService.getActiveNotifications();
      for (var event in notifications) {
        _handleIncomingNotification(event);
      }
      developer.log('Successfully synced ${notifications.length} existing notifications.');
    } catch (e) {
      developer.log('Error syncing existing notifications', error: e);
    }
  }

  Future<bool> checkPermission() async {
    try {
      return await NotificationListenerService.isPermissionGranted();
    } catch (e) {
      developer.log('Error checking permission', error: e);
      return false;
    }
  }

  Future<void> requestPermission() async {
    try {
      await NotificationListenerService.requestPermission();
    } catch (e) {
      developer.log('Error requesting permission', error: e);
    }
  }

  void startListening() {
    try {
      NotificationListenerService.notificationsStream.listen((ServiceNotificationEvent event) {
        _handleIncomingNotification(event);
      });
    } catch (e) {
      developer.log('Error starting listener', error: e);
    }
  }

  void _handleIncomingNotification(ServiceNotificationEvent event) {
    final packageName = event.packageName ?? '';
    final title = event.title ?? '';
    final body = event.content ?? '';

    developer.log('INCOMING NOTIFICATION Bypassing Whitelist: $packageName | Title: $title');

    // Ignore totally empty notifications safely
    if (title.isEmpty && body.isEmpty) return;

    // Notice we dropped the SupportedApps constraint completely temporarily to allow testing
    final appName = SupportedApps.getAppName(packageName, packageName);
    
    final detection = RuleEngine.analyze(title, body);

    final entity = NotificationEntity(
      appName: appName,
      packageName: packageName.isNotEmpty ? packageName : 'unknown.app',
      title: title,
      body: body,
      timestamp: DateTime.now(),
      isRead: false,
      riskLevel: detection.riskLevel,
      category: detection.category,
      matchedRules: detection.matchedRules,
      reason: detection.reason,
    );

    _alertEngine.processNotification(entity);

    // Branch to UPI protection logic
    _upiProtectionService.processUPINotification(entity);
  }
}
