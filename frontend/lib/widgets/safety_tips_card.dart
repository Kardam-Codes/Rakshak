import 'package:flutter/material.dart';

import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';

class SafetyTipsCard extends StatelessWidget {
  final List<String> tips;

  const SafetyTipsCard({super.key, required this.tips});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.textSecondary.withOpacity(0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Safety Tips',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.s12),
            for (final tip in tips) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, size: 18, color: AppColors.success),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(child: Text(tip)),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),
            ],
          ],
        ),
      ),
    );
  }
}
