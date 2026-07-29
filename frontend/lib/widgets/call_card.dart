import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/call_entity.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../engine/models/risk_level.dart';

class CallCard extends StatelessWidget {
  final CallEntity call;
  final VoidCallback onTap;

  const CallCard({
    Key? key,
    required this.call,
    required this.onTap,
  }) : super(key: key);

  Color _getRiskColor() {
    switch (call.riskLevel) {
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
    switch (call.riskLevel) {
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
                      'Call Alert',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _formatTime(call.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                call.phoneNumber,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (call.aiExplanation != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s12),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      call.aiExplanation!,
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
