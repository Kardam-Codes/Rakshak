import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/call_entity.dart';
import '../repositories/call_repository.dart';
import '../core/database/app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  // AppDatabase itself should be singleton or initialized in main
  return AppDatabase(); 
});

final callRepositoryProvider = Provider<CallRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CallRepository(db);
});

final callsProvider = StreamProvider<List<CallEntity>>((ref) {
  final repository = ref.watch(callRepositoryProvider);
  return repository.watchCalls();
});
