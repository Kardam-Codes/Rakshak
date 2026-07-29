import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/empty_state.dart';
import '../../core/constants/icons.dart';
import '../../core/constants/spacing.dart';
import 'widgets/notification_card.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(
              message: 'Rakshak is actively protecting your device.\nNo scam alerts yet.',
              icon: AppIcons.safe,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.s16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationCard(
                notification: notification,
                onTap: () {
                  context.push('/notification_detail', extra: notification);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => EmptyState(
          message: 'Error loading alerts.\n$error',
          icon: AppIcons.danger,
        ),
      ),
    );
  }
}
