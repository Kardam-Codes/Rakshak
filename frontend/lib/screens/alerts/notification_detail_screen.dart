import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/notification_entity.dart';
import '../../core/constants/spacing.dart';
import '../../providers/notification_provider.dart';
import '../../providers/database_provider.dart';
import '../../widgets/risk_badge.dart';
import '../../engine/models/scam_category.dart';
import '../../engine/models/risk_level.dart';

class NotificationDetailScreen extends ConsumerWidget {
  final NotificationEntity notification;

  const NotificationDetailScreen({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!notification.isRead && notification.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final db = ref.read(appDatabaseProvider);
          db.markAsRead(notification.id!);
        } catch (_) {}
      });
    }

    final isSafe = notification.riskLevel == RiskLevel.safe;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Details'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/alerts');
            }
          },
        ),
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
              RiskBadge(riskLevel: notification.riskLevel),
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
          const SizedBox(height: AppSpacing.s32),
          Text(
            'Analysis Strategy',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.s8),
          
          _buildInfoRow(context, 'Category', notification.category.displayName),
          
          if (!isSafe && notification.matchedRules.isNotEmpty)
             _buildInfoRow(context, 'Matched Rules', notification.matchedRules.join(', ')),

          _buildInfoRow(context, 'Reason', notification.reason),
          
          if (!isSafe) ... [
             const SizedBox(height: AppSpacing.s16),
             if (notification.aiSimpleExplanation == null && notification.riskLevel.index >= RiskLevel.medium.index) ... [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: AppSpacing.s16),
                      Text(
                        'AI Scam Guardian is analyzing...',
                        style: TextStyle(color: Theme.of(context).colorScheme.onTertiaryContainer, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                )
             ] else if (notification.aiSimpleExplanation != null) ... [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: AppSpacing.s8),
                          Text('AI Explanation', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          )),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        notification.aiSimpleExplanation!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      if (notification.aiReason != null) Text(notification.aiReason!),
                      const SizedBox(height: AppSpacing.s16),
                      if (notification.aiRecommendedAction != null)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.s16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.shield_outlined, size: 20, color: Theme.of(context).colorScheme.error),
                              const SizedBox(width: AppSpacing.s8),
                              Expanded(child: Text(
                                notification.aiRecommendedAction!,
                                style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
                              ))
                            ],
                          ),
                        ),
                    ],
                  ),
                )
             ],
          ],
          
          if (!isSafe) ... [
             const SizedBox(height: AppSpacing.s24),
             FilledButton.icon(
                onPressed: () {
                   context.push('/emergency', extra: notification.body);
                },
                icon: const Icon(Icons.security),
                label: const Text('Emergency Recovery Actions'),
                style: FilledButton.styleFrom(
                   backgroundColor: Theme.of(context).colorScheme.error,
                   foregroundColor: Theme.of(context).colorScheme.onError,
                   padding: const EdgeInsets.symmetric(vertical: 16),
                ),
             ),
          ]
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
