import '../../core/database/app_database.dart';
import '../../models/scan_entity.dart';

class ScanRepository {
  final AppDatabase _db;

  ScanRepository(this._db);

  Stream<List<ScanResultEntity>> watchScans() {
    return _db.scansStream;
  }

  Future<int> saveScan(ScanResultEntity entity) {
    return _db.insertScan(entity);
  }

  Future<ScanResultEntity?> findCachedScan(String content) {
    return _db.findCachedScan(content);
  }

  Future<void> deleteScan(int id) {
    return _db.deleteScan(id);
  }

  Future<void> clearScans() {
    return _db.clearScans();
  }
}
