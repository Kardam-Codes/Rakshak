import 'dart:developer' as developer;
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:notification_listener_service/notification_event.dart';
import '../repositories/notification_repository.dart';
import '../models/notification_entity.dart';
import '../repositories/call_repository.dart';
import '../config/supported_apps.dart';
import '../engine/rule_engine.dart';
import '../engine/alert_engine.dart';
import '../services/upi_protection_service.dart';
import '../repositories/upi_repository.dart';

class NotificationService {
  final NotificationRepository _repository;
  final CallRepository _callRepository;
  final UPIRepository _upiRepository;
  late final AlertEngine _alertEngine;
  late final UPIProtectionService _upiProtectionService;

  NotificationService(this._repository, this._callRepository, this._upiRepository) {
    _alertEngine = AlertEngine(_repository, _callRepository, _upiRepository, onCriticalAlert: _showCriticalPopupNative);
    _upiProtectionService = UPIProtectionService(_upiRepository, _alertEngine);
  }

  void _showCriticalPopupNative(NotificationEntity entity) {
     // Triggered into UI loop asynchronously if mapped via global navigation keys
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

    // Ignore empty/system notifications broadly if missing essential info
    if (packageName.isEmpty || title.isEmpty || body.isEmpty) return;

    if (SupportedApps.isSupported(packageName)) {
      final appName = SupportedApps.getAppName(packageName, packageName);
      
      final detection = RuleEngine.analyze(title, body);

      final entity = NotificationEntity(
        appName: appName,
        packageName: packageName,
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
    } else {
      developer.log('Notification ignored from: $packageName');
    }
  }
}
