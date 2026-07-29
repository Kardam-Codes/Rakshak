import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/upi_transaction_entity.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../engine/models/risk_level.dart';
import '../../engine/models/transaction_type.dart';

class UPIAlertCard extends StatelessWidget {
  final UPITransactionEntity transaction;
  final VoidCallback onTap;

  const UPIAlertCard({
    Key? key,
    required this.transaction,
    required this.onTap,
  }) : super(key: key);

  Color _getRiskColor() {
    switch (transaction.riskLevel) {
      case RiskLevel.safe:
        return AppColors.success;
      case RiskLevel.low:
        return AppColors.info;
      case RiskLevel.medium:
        return AppColors.warning;
      case RiskLevel.high:
      case RiskLevel.critical:
        return AppColors.danger;
    }
  }

  IconData _getRiskIcon() {
    switch (transaction.riskLevel) {
      case RiskLevel.safe:
        return Icons.verified_user_rounded;
      case RiskLevel.low:
        return Icons.info_outline_rounded;
      case RiskLevel.medium:
        return Icons.warning_amber_rounded;
      case RiskLevel.high:
      case RiskLevel.critical:
        return Icons.gpp_bad_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRiskColor();
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      color: color.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getRiskIcon(),
                    color: color,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Text(
                      transaction.transactionType == TransactionType.collectRequest 
                          ? 'Collect Request Detected' 
                          : 'Transaction Alert',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _formatTime(transaction.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                'Merchant: ${transaction.merchantName}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (transaction.upiId.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s4),
                  child: Text(
                    'UPI ID: ${transaction.upiId}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.s8),
              if (transaction.amount > 0)
                Text(
                  formatter.format(transaction.amount),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              if (transaction.aiExplanation != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s12),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      transaction.aiExplanation!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return DateFormat('h:mm a').format(time);
    }
    return DateFormat('MMM d, h:mm a').format(time);
  }
}
