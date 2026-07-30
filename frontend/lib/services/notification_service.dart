import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
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
import '../engine/explainability/explainability_engine.dart';
import '../engine/models/scam_category.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../repositories/explainability_repository.dart';
import '../routes/app_router.dart';
import 'trusted_family_service.dart';
import '../engine/models/risk_level.dart';

class NotificationService {
  static const MethodChannel _notificationChannel = MethodChannel('x-slayer/notifications_channel');

  final NotificationRepository _repository;
  final CallRepository _callRepository;
  final UPIRepository _upiRepository;
  late final UPIProtectionService _upiProtectionService;
  late final AlertEngine _alertEngine;
  StreamSubscription<ServiceNotificationEvent>? _subscription;
  bool _isListening = false;
  final Set<String> _recentlyHandledHashes = <String>{};

  NotificationService(
    this._repository,
    this._callRepository,
    this._upiRepository,
    TrustedFamilyService trustedFamilyService,
    ExplainabilityEngine explainEngine,
  ) {
    _alertEngine = AlertEngine(
      _repository,
      _callRepository,
      _upiRepository,
      explainEngine,
      onCriticalAlert: _showCriticalToast,
    );
    _upiProtectionService = UPIProtectionService(_upiRepository, _alertEngine);
  }

  void _showCriticalToast({required String title, required String category, required RiskLevel riskLevel}) async {
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
    if (context == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
        showCloseIcon: true,
        content: Text(
          '${riskLevel.name.toUpperCase()} ${ScamCategory.values.firstWhere((item) => item.name == category, orElse: () => ScamCategory.unknown).displayName}: $title',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => context.go('/alerts'),
        ),
      ),
    );
  }

  bool _shouldSkipDuplicate(ServiceNotificationEvent event) {
    final packageName = event.packageName ?? '';
    final title = event.title ?? '';
    final body = event.content ?? '';
    final key = '$packageName|$title|$body';

    if (_recentlyHandledHashes.contains(key)) return true;
    _recentlyHandledHashes.add(key);
    Future<void>.delayed(const Duration(seconds: 30), () {
      _recentlyHandledHashes.remove(key);
    });

    return false;
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

  Future<bool> isServiceConnected() async {
    try {
      return await _notificationChannel.invokeMethod<bool>('isServiceConnected') ?? false;
    } catch (e) {
      developer.log('Error checking notification listener connection', error: e);
      return false;
    }
  }

  Future<void> reconnectService() async {
    try {
      await _notificationChannel.invokeMethod('forceRequestRebind');
    } catch (e) {
      developer.log('forceRequestRebind failed; trying reconnectService', error: e);
    }

    try {
      await _notificationChannel.invokeMethod('reconnectService');
    } catch (e) {
      developer.log('Error reconnecting notification listener', error: e);
    }
  }

  Future<void> refreshListener() async {
    final permissionGranted = await checkPermission();
    if (!permissionGranted) return;

    startListening();
    final connected = await isServiceConnected();
    if (!connected) {
      await reconnectService();
      await Future<void>.delayed(const Duration(milliseconds: 700));
    }
    await syncExistingNotifications();
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
    if (_isListening) return;
    _isListening = true;

    try {
      _subscription = NotificationListenerService.notificationsStream.listen((ServiceNotificationEvent event) {
        _handleIncomingNotification(event);
      }, onError: (Object error) {
        _isListening = false;
        developer.log('Notification listener error', error: error);
      }, onDone: () {
        _isListening = false;
      });
    } catch (e) {
      _isListening = false;
      developer.log('Error starting listener', error: e);
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
  }

  void _handleIncomingNotification(ServiceNotificationEvent event) {
    final packageName = event.packageName ?? '';
    final title = event.title ?? '';
    final body = event.content ?? '';

    developer.log('INCOMING NOTIFICATION Bypassing Whitelist: $packageName | Title: $title');

    // Ignore totally empty notifications safely
    if (title.isEmpty && body.isEmpty) return;
    if (_shouldSkipDuplicate(event)) return;

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
