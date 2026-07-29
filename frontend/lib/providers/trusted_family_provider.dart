import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/app_database.dart';
import '../models/trusted_contact.dart';
import '../models/family_alert_history.dart';
import '../repositories/trusted_family_repository.dart';
import '../services/trusted_family_analytics_service.dart';
import '../services/trusted_family_service.dart';
import 'scan_provider.dart';

final trustedFamilyRepositoryProvider = Provider<TrustedFamilyRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TrustedFamilyRepository(db);
});

final trustedFamilyAnalyticsServiceProvider = Provider<TrustedFamilyAnalyticsService>((ref) {
  final analytics = TrustedFamilyAnalyticsService();
  analytics.init();
  return analytics;
});

final trustedFamilyServiceProvider = Provider<TrustedFamilyService>((ref) {
  final repository = ref.watch(trustedFamilyRepositoryProvider);
  final db = ref.watch(appDatabaseProvider);
  final analytics = ref.watch(trustedFamilyAnalyticsServiceProvider);
  return TrustedFamilyService(
    repository: repository,
    db: db,
    analyticsService: analytics,
  );
});

final trustedContactsStreamProvider = StreamProvider<List<TrustedContact>>((ref) {
  final repository = ref.watch(trustedFamilyRepositoryProvider);
  return repository.watchContacts();
});

final familyHistoryStreamProvider = StreamProvider<List<FamilyAlertHistoryEntity>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.familyHistoryStream;
});
