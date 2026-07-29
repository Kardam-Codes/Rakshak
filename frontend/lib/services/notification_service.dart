import 'dart:developer' as developer;
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:notification_listener_service/notification_event.dart';
import '../repositories/notification_repository.dart';
import '../models/notification_entity.dart';
import '../config/supported_apps.dart';

class NotificationService {
  final NotificationRepository _repository;

  NotificationService(this._repository);

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
      
      final entity = NotificationEntity(
        appName: appName,
        packageName: packageName,
        title: title,
        body: body,
        timestamp: DateTime.now(),
        isRead: false,
      );

      _repository.saveNotification(entity).then((_) {
        developer.log('Notification stored: $packageName');
      }).catchError((e) {
        developer.log('Error saving notification', error: e);
      });
    } else {
      developer.log('Notification ignored from: $packageName');
    }
  }
}
