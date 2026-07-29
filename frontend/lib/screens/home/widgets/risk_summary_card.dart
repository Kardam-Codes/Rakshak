import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../engine/models/risk_level.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/call_provider.dart';
import '../../../core/constants/spacing.dart';

class RiskSummaryCard extends ConsumerWidget {
  const RiskSummaryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final callsAsync = ref.watch(callsProvider);
    
    // Simplistic loading state fallback
    if (notificationsAsync.isLoading || callsAsync.isLoading) {
       return const Center(child: CircularProgressIndicator());
    }

    final notifications = notificationsAsync.value ?? [];
    final calls = callsAsync.value ?? [];

    final today = DateTime.now();
    
    final todayNotifications = notifications.where((n) => 
      n.timestamp.day == today.day && n.timestamp.month == today.month && n.timestamp.year == today.year
    ).toList();
    
    final todayCalls = calls.where((c) => 
      c.timestamp.day == today.day && c.timestamp.month == today.month && c.timestamp.year == today.year
    ).toList();
    
    final safeCount = todayNotifications.where((n) => n.riskLevel == RiskLevel.safe).length +
                      todayCalls.where((c) => c.riskLevel == RiskLevel.safe).length;

    final highCount = todayNotifications.where((n) => n.riskLevel == RiskLevel.high).length +
                      todayCalls.where((c) => c.riskLevel == RiskLevel.high).length;

    final criticalCount = todayNotifications.where((n) => n.riskLevel == RiskLevel.critical).length +
                          todayCalls.where((c) => c.riskLevel == RiskLevel.critical).length;

    final total = todayNotifications.length + todayCalls.length;

    return Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol(context, 'Total Events', total.toString(), Colors.blue),
                    _buildStatCol(context, 'Safe', safeCount.toString(), Colors.green),
                    _buildStatCol(context, 'High Risk', highCount.toString(), Colors.orange),
                    _buildStatCol(context, 'Critical', criticalCount.toString(), Colors.red),
                  ]
                )
              ]
            )
          )
        );
  }

  Widget _buildStatCol(BuildContext context, String label, String count, Color color) {
    return Column(
      children: [
        Text(count, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ]
    );
  }
}
