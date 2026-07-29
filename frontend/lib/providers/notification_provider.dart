import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/app_database.dart';
import '../repositories/notification_repository.dart';
import '../services/notification_service.dart';
import '../models/notification_entity.dart';
import 'call_provider.dart';
import 'upi_provider.dart';
import '../repositories/explainability_repository.dart';
import '../engine/explainability/explainability_engine.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final explainabilityRepositoryProvider = Provider<ExplainabilityRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ExplainabilityRepository(db);
});

final explainabilityEngineProvider = Provider<ExplainabilityEngine>((ref) {
  final repo = ref.watch(explainabilityRepositoryProvider);
  return ExplainabilityEngine(repo);
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return NotificationRepository(db);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  final callRepo = ref.watch(callRepositoryProvider);
  final upiRepo = ref.watch(upiRepositoryProvider);
  final explainEngine = ref.watch(explainabilityEngineProvider);
  return NotificationService(repo, callRepo, upiRepo, explainEngine);
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
    }
  }

  Future<void> requestPermission() async {
    await _service.requestPermission();
    // Re-check happens on lifecycle resume
  }
}
