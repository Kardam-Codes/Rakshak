import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/empty_state.dart';
import '../../core/constants/icons.dart';
import '../../core/constants/spacing.dart';
import 'widgets/notification_card.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AlertsScreen> createState() => AlertsScreenState();
}

class AlertsScreenState extends ConsumerState<AlertsScreen> {
  String selectedFilter = 'All';
  final filters = ['All', 'Safe', 'Low', 'Medium', 'High', 'Critical'];

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
            child: Row(
              children: filters.map((f) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.s8),
                child: FilterChip(
                  label: Text(f),
                  selected: selectedFilter == f,
                  onSelected: (val) {
                    setState(() => selectedFilter = f);
                  },
                ),
              )).toList(),
            ),
          ),
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) {
                final filtered = notifications.where((n) {
                  if (selectedFilter == 'All') return true;
                  return n.riskLevel.name.toLowerCase() == selectedFilter.toLowerCase();
                }).toList();

                if (filtered.isEmpty) {
                  return const EmptyState(
                    message: 'No alerts match the selected filter.',
                    icon: AppIcons.safe,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final notification = filtered[index];
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
          ),
        ],
      ),
    );
  }
}
