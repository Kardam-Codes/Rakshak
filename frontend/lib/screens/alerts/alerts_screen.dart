import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/notification_provider.dart';
import '../../providers/call_provider.dart';
import '../../providers/upi_provider.dart';
import '../../models/notification_entity.dart';
import '../../engine/models/risk_level.dart';
import '../../engine/models/scam_category.dart';
import '../../models/call_entity.dart';
import '../../models/upi_transaction_entity.dart';
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

enum AlertType { all, message, call, upi, otp }

class AlertsScreenState extends ConsumerState<AlertsScreen> {
  AlertType _selectedType = AlertType.all;
  bool _hideSafe = false;

  void _navigateToDetail(BuildContext context, dynamic item, String type) {
    if (item is NotificationEntity) {
       if (item.category == ScamCategory.otpScam) {
         context.push('/otp_detail', extra: item);
       } else {
         context.push('/alerts/notification_detail', extra: item);
       }
    } else if (item is CallEntity) {
       context.push('/alerts/call_detail', extra: item);
    } else if (item is UPITransactionEntity) {
       context.push('/alerts/transaction_detail', extra: item);
    }
  }

  bool _isCallNotification(NotificationEntity n) {
      final pkg = n.packageName.toLowerCase();
      return pkg.contains('dialer') || pkg.contains('telecom') || pkg.contains('incallui');
  }

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
            padding: const EdgeInsets.only(top: AppSpacing.s16, left: AppSpacing.s16, right: AppSpacing.s16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<AlertType>(
                segments: const [
                  ButtonSegment(value: AlertType.all, label: Text('All')),
                  ButtonSegment(value: AlertType.message, label: Text('Messages')),
                  ButtonSegment(value: AlertType.call, label: Text('Calls')),
                  ButtonSegment(value: AlertType.upi, label: Text('UPI')),
                  ButtonSegment(value: AlertType.otp, label: Text('OTPs')),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<AlertType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
              ),
            ),
          ),
          CheckboxListTile(
             title: const Text('Hide Safe Notifications', style: TextStyle(fontWeight: FontWeight.w500)),
             value: _hideSafe,
             onChanged: (val) {
                 setState(() {
                    _hideSafe = val ?? false;
                 });
             },
             controlAffinity: ListTileControlAffinity.leading,
             dense: true,
             contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
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
                           
                           final filteredNotifications = notifications.where((n) => !_isCallNotification(n)).toList();

                           if (_selectedType == AlertType.all) {
                              combined.addAll(filteredNotifications);
                           } else if (_selectedType == AlertType.message) {
                              combined.addAll(filteredNotifications.where((n) => n.category != ScamCategory.otpScam));
                           } else if (_selectedType == AlertType.otp) {
                              combined.addAll(filteredNotifications.where((n) => n.category == ScamCategory.otpScam));
                           } else if (_selectedType == AlertType.call) {
                              combined.addAll(notifications.where((n) => _isCallNotification(n)));
                           }

                           if (_selectedType == AlertType.all || _selectedType == AlertType.call) combined.addAll(calls);
                           if (_selectedType == AlertType.all || _selectedType == AlertType.upi) combined.addAll(upis);

                           // Hide Safe
                           if (_hideSafe) {
                               combined = combined.where((item) => item.riskLevel != RiskLevel.safe).toList();
                           }

                           // Deduplicate List based on Type, Core Content, and 5-min threshold
                           final List<dynamic> deduplicated = [];
                           for (final item in combined) {
                               bool isDuplicate = false;
                               for (final existing in deduplicated) {
                                   if (item.runtimeType != existing.runtimeType) continue;
                                   
                                   if (item is NotificationEntity && existing is NotificationEntity) {
                                       if (item.title == existing.title && item.body == existing.body && item.timestamp.difference(existing.timestamp).inMinutes.abs() < 5) {
                                           isDuplicate = true; break;
                                       }
                                   } else if (item is CallEntity && existing is CallEntity) {
                                       if (item.phoneNumber == existing.phoneNumber && item.timestamp.difference(existing.timestamp).inMinutes.abs() < 5) {
                                           isDuplicate = true; break;
                                       }
                                   } else if (item is UPITransactionEntity && existing is UPITransactionEntity) {
                                       if (item.upiId == existing.upiId && item.amount == existing.amount && item.timestamp.difference(existing.timestamp).inMinutes.abs() < 5) {
                                           isDuplicate = true; break;
                                       }
                                   }
                               }
                               if (!isDuplicate) deduplicated.add(item);
                           }

                           // Sort
                           deduplicated.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                           if (deduplicated.isEmpty) {
                              return const EmptyState(
                                message: 'No alerts match the selected filter.',
                                icon: AppIcons.safe,
                              );
                           }

                           return ListView.builder(
                             padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                             itemCount: deduplicated.length,
                             itemBuilder: (context, index) {
                               final item = deduplicated[index];
                               if (item is NotificationEntity) {
                                  return NotificationCard(
                                    notification: item,
                                    onTap: () => _navigateToDetail(context, item, 'notification'),
                                  );
                               } else if (item is CallEntity) {
                                  return CallCard(
                                    call: item,
                                    onTap: () => _navigateToDetail(context, item, 'call'),
                                  );
                               } else {
                                  return UPIAlertCard(
                                    transaction: item,
                                    onTap: () => _navigateToDetail(context, item, 'upi'),
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

