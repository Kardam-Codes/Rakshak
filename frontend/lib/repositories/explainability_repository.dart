import '../../core/database/app_database.dart';
import '../../models/explanation_entity.dart';

class ExplainabilityRepository {
  final AppDatabase _db;

  ExplainabilityRepository(this._db);

  Future<int> saveExplanation(ExplanationEntity entity) async {
    if (entity.id != null) {
      await _db.updateExplanation(entity);
      return entity.id!;
    } else {
      return await _db.insertExplanation(entity);
    }
  }

  Future<void> updateExplanation(ExplanationEntity entity) async {
    await _db.updateExplanation(entity);
  }

  ExplanationEntity? findExplanationByHash(String hash) {
    return _db.getExplanationByHash(hash);
  }
}
