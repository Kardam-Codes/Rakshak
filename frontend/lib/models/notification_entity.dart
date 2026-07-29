class NotificationEntity {
  final int? id;
  final String appName;
  final String packageName;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;

  NotificationEntity({
    this.id,
    required this.appName,
    required this.packageName,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
  });

  NotificationEntity copyWith({
    int? id,
    String? appName,
    String? packageName,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
