import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/explainability_repository.dart';
import '../engine/explainability/explainability_engine.dart';
import 'database_provider.dart';

final explainabilityRepositoryProvider = Provider<ExplainabilityRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ExplainabilityRepository(db);
});

final explainabilityEngineProvider = Provider<ExplainabilityEngine>((ref) {
  final repo = ref.watch(explainabilityRepositoryProvider);
  return ExplainabilityEngine(repo);
});
