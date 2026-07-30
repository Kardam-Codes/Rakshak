import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/call_entity.dart';
import '../repositories/call_repository.dart';
import '../core/database/app_database.dart';

import 'database_provider.dart';
import '../services/call_detection_service.dart';
import '../services/number_reputation_service.dart';

final callRepositoryProvider = Provider<CallRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CallRepository(db);
});

final callsProvider = StreamProvider<List<CallEntity>>((ref) {
  final repository = ref.watch(callRepositoryProvider);
  return repository.watchCalls();
});

final numberReputationServiceProvider = Provider<NumberReputationService>((ref) {
  return MockReputationService();
});

final callDetectionServiceProvider = Provider<CallDetectionService>((ref) {
  final callRepo = ref.watch(callRepositoryProvider);
  final reputationService = ref.watch(numberReputationServiceProvider);
  final service = CallDetectionService(callRepo, reputationService);
  
  // Asynchronously spawn phone state observation loops
  service.initialize();
  return service;
});
