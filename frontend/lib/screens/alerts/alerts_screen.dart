import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/notification_provider.dart';
import '../../providers/call_provider.dart';
import '../../providers/upi_provider.dart';
import '../../models/notification_entity.dart';
import '../../models/call_entity.dart';
import '../../widgets/empty_state.dart';
import '../../core/constants/icons.dart';
import '../../core/constants/spacing.dart';
import '../../widgets/upi_alert_card.dart';
import '../../widgets/call_card.dart';
import 'widgets/notification_card.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AlertsScreen> createState() => AlertsScreenState();
}

enum AlertType { all, message, call, upi }

class AlertsScreenState extends ConsumerState<AlertsScreen> {
  AlertType _selectedType = AlertType.all;

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final callsAsync = ref.watch(callsProvider);
    final upiAsync = ref.watch(upiTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts Center'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: SegmentedButton<AlertType>(
              segments: const [
                ButtonSegment(value: AlertType.all, label: Text('All')),
                ButtonSegment(value: AlertType.message, label: Text('Messages')),
                ButtonSegment(value: AlertType.call, label: Text('Calls')),
                ButtonSegment(value: AlertType.upi, label: Text('UPI')),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<AlertType> newSelection) {
                setState(() {
                  _selectedType = newSelection.first;
                });
              },
            ),
          ),
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) {
                return callsAsync.when(
                  data: (calls) {
                     return upiAsync.when(
                        data: (upis) {
                           // Aggregate
                           List<dynamic> combined = [];
                           if (_selectedType == AlertType.all || _selectedType == AlertType.message) combined.addAll(notifications);
                           if (_selectedType == AlertType.all || _selectedType == AlertType.call) combined.addAll(calls);
                           if (_selectedType == AlertType.all || _selectedType == AlertType.upi) combined.addAll(upis);

                           // Sort
                           combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                           if (combined.isEmpty) {
                              return const EmptyState(
                                message: 'No alerts match the selected filter.',
                                icon: AppIcons.safe,
                              );
                           }

                           return ListView.builder(
                             padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                             itemCount: combined.length,
                             itemBuilder: (context, index) {
                               final item = combined[index];
                               if (item is NotificationEntity) {
                                  return NotificationCard(
                                    notification: item,
                                    onTap: () => context.push('/alerts/notification_detail', extra: item),
                                  );
                               } else if (item is CallEntity) {
                                  return CallCard(
                                    call: item,
                                    onTap: () => context.push('/alerts/call_detail', extra: item),
                                  );
                               } else {
                                  return UPIAlertCard(
                                    transaction: item,
                                    onTap: () => context.push('/alerts/transaction_detail', extra: item),
                                  );
                               }
                             },
                           );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Center(child: Text('Error: $err')),
                     );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
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

