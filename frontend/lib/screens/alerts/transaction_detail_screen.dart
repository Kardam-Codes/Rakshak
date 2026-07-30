import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/upi_transaction_entity.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../engine/models/risk_level.dart';
import '../../engine/models/transaction_type.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_title.dart';

class TransactionDetailScreen extends StatelessWidget {
  final UPITransactionEntity transaction;

  const TransactionDetailScreen({Key? key, required this.transaction}) : super(key: key);

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getRiskIcon(), color: color, size: 48),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Center(
              child: Text(
                transaction.transactionType == TransactionType.collectRequest 
                    ? 'Payment Request' 
                    : transaction.transactionType.name.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Center(
              child: Text(
                formatter.format(transaction.amount),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s32),

            const SectionTitle(title: 'Overview'),
            _buildDetailRow(context, 'Merchant', transaction.merchantName),
            if (transaction.upiId.isNotEmpty)
              _buildDetailRow(context, 'UPI ID', transaction.upiId),
            _buildDetailRow(context, 'App', transaction.appName),
            _buildDetailRow(context, 'Date & Time', DateFormat('MMM d, y, h:mm a').format(transaction.timestamp)),
            _buildDetailRow(context, 'Risk Profile', transaction.riskLevel.name.toUpperCase(), valueColor: color),

            const SizedBox(height: AppSpacing.s24),
            const SectionTitle(title: 'AI Analysis'),
            if (transaction.aiExplanation == null) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.s16),
                  child: CircularProgressIndicator(),
                ),
              ),
              const Center(child: Text('AI analyzing transaction patterns...')),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.aiExplanation!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Text(
                      'Recommendation:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      transaction.recommendedAction ?? 'Verify before proceeding.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              ),
            ],
            
            if (transaction.riskLevel.index >= RiskLevel.medium.index) ... [
               const SizedBox(height: AppSpacing.s32),
               SizedBox(
                 width: double.infinity,
                 child: FilledButton.icon(
                    onPressed: () {
                       context.push('/emergency', extra: 'Suspicious Transaction Detected: ${transaction.merchantName} (Amount: ${formatter.format(transaction.amount)})');
                    },
                    icon: const Icon(Icons.security),
                    label: const Text('Emergency Recovery Actions'),
                    style: FilledButton.styleFrom(
                       backgroundColor: Theme.of(context).colorScheme.error,
                       foregroundColor: Theme.of(context).colorScheme.onError,
                       padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                 ),
               ),
            ],

            const SizedBox(height: AppSpacing.s24),
            PrimaryButton(
              onPressed: () => Navigator.pop(context),
              text: 'Acknowledge',
              backgroundColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
