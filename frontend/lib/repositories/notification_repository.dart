import '../../core/database/app_database.dart';
import '../../models/notification_entity.dart';

class NotificationRepository {
  final AppDatabase _db;

  NotificationRepository(this._db);

  Stream<List<NotificationEntity>> watchNotifications() {
    return _db.notificationsStream;
  }

  Future<void> saveNotification(NotificationEntity entity) {
    return _db.insertNotification(entity);
  }

  Future<void> deleteNotification(int id) {
    return _db.deleteNotification(id);
  }

  Future<void> clearNotifications() {
    return _db.clearNotifications();
  }
}
