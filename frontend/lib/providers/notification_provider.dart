import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/app_database.dart';
import '../repositories/notification_repository.dart';
import '../services/notification_service.dart';
import '../models/notification_entity.dart';
import 'database_provider.dart';
import 'call_provider.dart';
import 'upi_provider.dart';
import 'trusted_family_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return NotificationRepository(db);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  final callRepo = ref.watch(callRepositoryProvider);
  final upiRepo = ref.watch(upiRepositoryProvider);
  final trustedFamilyService = ref.watch(trustedFamilyServiceProvider);
  return NotificationService(repo, callRepo, upiRepo, trustedFamilyService);
});

final notificationsProvider = StreamProvider<List<NotificationEntity>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.watchNotifications();
});

final notificationPermissionProvider = StateNotifierProvider<NotificationPermissionNotifier, bool>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationPermissionNotifier(service);
});

class NotificationPermissionNotifier extends StateNotifier<bool> with WidgetsBindingObserver {
  final NotificationService _service;

  NotificationPermissionNotifier(this._service) : super(false) {
    WidgetsBinding.instance.addObserver(this);
    checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkPermission(); // Recheck permission when returning to app
    }
  }

  Future<void> checkPermission() async {
    final isGranted = await _service.checkPermission();
    if (isGranted != state) {
      state = isGranted;
    }
    if (isGranted) {
      _service.startListening();
      await _service.syncExistingNotifications();
    }
  }

  Future<void> requestPermission() async {
    await _service.requestPermission();
    // Re-check happens on lifecycle resume
  }
}
