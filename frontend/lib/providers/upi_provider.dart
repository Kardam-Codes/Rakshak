import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/upi_transaction_entity.dart';
import '../repositories/upi_repository.dart';
import 'database_provider.dart';

final upiRepositoryProvider = Provider<UPIRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return UPIRepository(db);
});

final upiTransactionsProvider = StreamProvider<List<UPITransactionEntity>>((ref) {
  final repo = ref.watch(upiRepositoryProvider);
  return repo.watchTransactions();
});
