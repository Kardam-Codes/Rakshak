import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/notification_entity.dart';

class NotificationEntityAdapter extends TypeAdapter<NotificationEntity> {
  @override
  final int typeId = 0;

  @override
  NotificationEntity read(BinaryReader reader) {
    return NotificationEntity(
      id: reader.read(),
      appName: reader.read(),
      packageName: reader.read(),
      title: reader.read(),
      body: reader.read(),
      timestamp: reader.read(),
      isRead: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, NotificationEntity obj) {
    writer.write(obj.id);
    writer.write(obj.appName);
    writer.write(obj.packageName);
    writer.write(obj.title);
    writer.write(obj.body);
    writer.write(obj.timestamp);
    writer.write(obj.isRead);
  }
}

class AppDatabase {
  static const String _boxName = 'notifications_box';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NotificationEntityAdapter());
    await Hive.openBox<NotificationEntity>(_boxName);
  }

  Box<NotificationEntity> get _box => Hive.box<NotificationEntity>(_boxName);

  Stream<List<NotificationEntity>> watchNotifications() {
    return _box.watch().map((_) => _getAllSorted()).asBroadcastStream()
      ..listen((_) {}) // force active
      // Yield the initial value immediately
      ;
  }

  Stream<List<NotificationEntity>> get notificationsStream async* {
    yield _getAllSorted();
    yield* watchNotifications();
  }

  List<NotificationEntity> _getAllSorted() {
    final list = _box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<int> insertNotification(NotificationEntity entity) async {
    final id = await _box.add(entity);
    // update with ID
    final updated = entity.copyWith(id: id);
    await _box.put(id, updated);
    return id;
  }

  Future<void> deleteNotification(int id) async {
    await _box.delete(id);
  }

  Future<void> clearNotifications() async {
    await _box.clear();
  }

  Future<void> markAsRead(int id) async {
    final entity = _box.get(id);
    if (entity != null) {
      await _box.put(id, entity.copyWith(isRead: true));
    }
  }
}
