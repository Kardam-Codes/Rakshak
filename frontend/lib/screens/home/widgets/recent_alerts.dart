import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/icons.dart';
import '../../../providers/notification_provider.dart';
import '../../../engine/models/scam_category.dart';

class RecentAlerts extends ConsumerWidget {
  const RecentAlerts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Alerts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.s8),
                child: Text('No recent alerts.'),
              );
            }
            final recent = notifications.take(5).toList();
            return Column(
              children: recent.map((notif) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(AppIcons.alerts, color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(
                  notif.title,
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${notif.appName} • ${notif.timestamp.hour}:${notif.timestamp.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  if (notif.category == ScamCategory.otpScam) {
                    context.push('/otp_detail', extra: notif);
                  } else {
                    context.push('/alerts/notification_detail', extra: notif);
                  }
                },
              )).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Error loading alerts.'),
        ),
      ],
    );
  }
}
