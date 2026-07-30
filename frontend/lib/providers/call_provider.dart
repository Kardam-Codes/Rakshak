import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/call_entity.dart';
import '../repositories/call_repository.dart';
import '../core/database/app_database.dart';

import 'database_provider.dart';

final callRepositoryProvider = Provider<CallRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CallRepository(db);
});

final callsProvider = StreamProvider<List<CallEntity>>((ref) {
  final repository = ref.watch(callRepositoryProvider);
  return repository.watchCalls();
});
