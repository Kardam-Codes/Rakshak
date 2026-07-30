import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/notification_provider.dart';
import '../../providers/call_provider.dart';
import '../../providers/upi_provider.dart';
import '../../models/notification_entity.dart';
import '../../engine/models/scam_category.dart';
import '../../models/call_entity.dart';
import '../../models/upi_transaction_entity.dart';
import '../../widgets/empty_state.dart';
import '../../core/constants/icons.dart';
import '../../core/constants/spacing.dart';
import '../../widgets/upi_alert_card.dart';
import '../../widgets/call_card.dart';
import 'widgets/notification_card.dart';
import '../../models/explanation_entity.dart';
import '../../engine/explainability/templates/explanation_templates.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AlertsScreen> createState() => AlertsScreenState();
}

enum AlertType { all, message, call, upi, otp }

class AlertsScreenState extends ConsumerState<AlertsScreen> {
  AlertType _selectedType = AlertType.all;

  void _navigateToDetail(BuildContext context, dynamic item, String type) {
    late ExplanationEntity entity;
    late String title;
    late String subtitle;

    if (item is NotificationEntity) {
       if (item.category == ScamCategory.otpScam) {
         context.push('/otp_detail', extra: item);
         return;
       }

       final template = ExplanationTemplateBuilder.build(item.category);
       entity = ExplanationEntity(
          sourceFeature: 'notification',
          category: item.category.name,
          riskLevel: item.riskLevel,
          confidence: 0.8,
          offlineExplanation: item.reason,
          aiExplanation: item.aiReason,
          recommendedAction: item.aiRecommendedAction,
          preventionTips: template['preventionTips']?.cast<String>() ?? [],
          summary: item.aiSimpleExplanation ?? 'Suspicious Activity',
          createdAt: item.timestamp,
          contentHash: item.notificationHash ?? '',
       );
       title = item.appName;
       subtitle = item.title;
    } else if (item is CallEntity) {
       final template = ExplanationTemplateBuilder.build(item.category);
       entity = ExplanationEntity(
          sourceFeature: 'call',
          category: item.category.name,
          riskLevel: item.riskLevel,
          confidence: 0.8,
          offlineExplanation: item.offlineReason,
          aiExplanation: item.aiExplanation,
          recommendedAction: item.aiRecommendedAction,
          preventionTips: template['preventionTips']?.cast<String>() ?? [],
          summary: item.aiExplanation != null ? 'Call Analysis Complete' : 'Flagged Offline',
          createdAt: item.timestamp,
          contentHash: '',
       );
       title = item.contactName ?? item.phoneNumber;
       subtitle = 'Duration: ${item.durationSeconds}s';
    } else if (item is UPITransactionEntity) {
       final template = ExplanationTemplateBuilder.build(item.category);
       entity = ExplanationEntity(
          sourceFeature: 'upi',
          category: item.category.name,
          riskLevel: item.riskLevel,
          confidence: item.confidence,
          offlineExplanation: item.offlineReason,
          aiExplanation: item.aiExplanation,
          recommendedAction: item.recommendedAction,
          preventionTips: template['preventionTips']?.cast<String>() ?? [],
          summary: item.aiExplanation != null ? 'Transaction Analysis Complete' : 'Flagged Offline',
          createdAt: item.timestamp,
          contentHash: '',
       );
       title = item.merchantName;
       subtitle = 'INR ${item.amount.toStringAsFixed(2)} - ${item.transactionType.name}';
    }

    context.push('/alerts/explain_detail', extra: {
        'entity': entity,
        'title': title,
        'subtitle': subtitle,
    });
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
            padding: const EdgeInsets.all(AppSpacing.s16),
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
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) {
                return callsAsync.when(
                  data: (calls) {
                     return upiAsync.when(
                        data: (upis) {
                           // Aggregate
                           List<dynamic> combined = [];
                           if (_selectedType == AlertType.all) {
                              combined.addAll(notifications);
                           } else if (_selectedType == AlertType.message) {
                              combined.addAll(notifications.where((n) => n.category != ScamCategory.otpScam));
                           } else if (_selectedType == AlertType.otp) {
                              combined.addAll(notifications.where((n) => n.category == ScamCategory.otpScam));
                           }

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

