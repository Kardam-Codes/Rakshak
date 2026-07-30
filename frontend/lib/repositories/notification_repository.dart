import '../../core/database/app_database.dart';
import '../../models/notification_entity.dart';

class NotificationRepository {
  final AppDatabase _db;

  NotificationRepository(this._db);

  AppDatabase get database => _db;

  Stream<List<NotificationEntity>> watchNotifications() {
    return _db.notificationsStream;
  }

  Future<int> saveNotification(NotificationEntity entity) {
    return _db.insertNotification(entity);
  }

  Future<void> deleteNotification(int id) {
    return _db.deleteNotification(id);
  }

  Future<void> clearNotifications() {
    return _db.clearNotifications();
  }

  Future<NotificationEntity?> findNotificationByHashWithAi(String hash) {
    return _db.findNotificationByHashWithAi(hash);
  }

  Future<NotificationEntity?> findNotificationByHash(String hash) async {
    return _db.findNotificationByHash(hash);
  }

  Future<void> updateNotification(NotificationEntity entity) {
    return _db.updateNotification(entity);
  }
}
