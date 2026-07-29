import '../core/database/app_database.dart';
import '../models/call_entity.dart';

class CallRepository {
  final AppDatabase _db;

  CallRepository(this._db);

  Stream<List<CallEntity>> watchCalls() {
    return _db.callsStream;
  }

  Future<int> saveCall(CallEntity entity) {
    return _db.insertCall(entity);
  }

  Future<void> updateCall(CallEntity entity) {
    return _db.updateCall(entity);
  }

  Future<void> deleteCall(int id) {
    return _db.deleteCall(id);
  }

  Future<void> clearHistory() {
    return _db.clearCalls();
  }
}
