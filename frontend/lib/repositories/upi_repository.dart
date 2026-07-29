import '../core/database/app_database.dart';
import '../models/upi_transaction_entity.dart';

class UPIRepository {
  final AppDatabase _db;

  UPIRepository(this._db);

  Stream<List<UPITransactionEntity>> watchTransactions() {
    return _db.upiTransactionsStream;
  }

  Future<int> saveTransaction(UPITransactionEntity transaction) async {
    if (transaction.id != null) {
      await _db.updateUpiTransaction(transaction);
      return transaction.id!;
    } else {
      return await _db.insertUpiTransaction(transaction);
    }
  }

  Future<void> updateTransactionExplanation(int id, String aiExplanation, String? recommendedAction) async {
    final list = _db.upiTransactionsStream.first; // This is a bit inefficient synchronously
    final all = await list;
    try {
      final transaction = all.firstWhere((element) => element.id == id);
      final updated = transaction.copyWith(
        aiExplanation: aiExplanation,
        recommendedAction: recommendedAction ?? transaction.recommendedAction,
      );
      await _db.updateUpiTransaction(updated);
    } catch (_) {
      // Transaction not found
    }
  }

  Future<void> deleteTransaction(int id) async {
    await _db.deleteUpiTransaction(id);
  }

  Future<void> clearTransactions() async {
    await _db.clearUpiTransactions();
  }
}
