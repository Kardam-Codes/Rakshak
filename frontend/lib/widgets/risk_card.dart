import 'package:flutter/material.dart';
import '../core/constants/spacing.dart';
import '../core/constants/colors.dart';

enum RiskLevel { safe, warning, danger }

class RiskCard extends StatelessWidget {
  final String title;
  final String description;
  final RiskLevel level;
  final IconData icon;
  final VoidCallback action;
  final String actionText;

  const RiskCard({
    super.key,
    required this.title,
    required this.description,
    required this.level,
    required this.icon,
    required this.action,
    required this.actionText,
  });

  Color _getRiskColor() {
    switch (level) {
      case RiskLevel.safe:
        return AppColors.success;
      case RiskLevel.warning:
        return AppColors.warning;
      case RiskLevel.danger:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: riskColor, size: 28),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: riskColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.s16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: action,
                style: TextButton.styleFrom(foregroundColor: riskColor),
                child: Text(actionText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
