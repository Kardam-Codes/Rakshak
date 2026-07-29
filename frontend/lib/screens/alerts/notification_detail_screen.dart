import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/notification_entity.dart';
import '../../core/constants/spacing.dart';
import '../../providers/notification_provider.dart';

class NotificationDetailScreen extends ConsumerWidget {
  final NotificationEntity notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!notification.isRead && notification.id != null) {
      // Mark as read immediately when viewed, but safely inside a post-frame callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final db = ref.read(appDatabaseProvider);
          db.markAsRead(notification.id!);
        } catch (_) {}
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [
          Row(
            children: [
              const Icon(Icons.notifications, size: 48),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.appName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      notification.packageName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      '${notification.timestamp.day}/${notification.timestamp.month}/${notification.timestamp.year} ${notification.timestamp.hour}:${notification.timestamp.minute.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s24),
          const Divider(),
          const SizedBox(height: AppSpacing.s16),
          Text(
            notification.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            notification.body,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
