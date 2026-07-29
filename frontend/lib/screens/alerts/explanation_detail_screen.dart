import 'package:flutter/material.dart';
import '../../models/explanation_entity.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../widgets/explainability/explanation_card.dart';
import '../../widgets/explainability/recommendation_card.dart';
import '../../widgets/explainability/prevention_tips_card.dart';
import '../../widgets/explainability/confidence_badge.dart';

class ExplanationDetailScreen extends StatelessWidget {
  final ExplanationEntity entity;
  final String contextTitle;
  final String contextSubtitle;

  const ExplanationDetailScreen({
    super.key,
    required this.entity,
    required this.contextTitle,
    required this.contextSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Threat Analysis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Context
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(
                         contextTitle,
                         style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                       ),
                       ConfidenceBadge(confidence: entity.confidence),
                     ],
                   ),
                   const SizedBox(height: AppSpacing.s8),
                   Text(
                     contextSubtitle,
                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                       color: AppColors.textSecondaryLight,
                     ),
                   ),
                   const SizedBox(height: AppSpacing.s16),
                   Text(
                     'Category: ${entity.category}',
                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                       color: AppColors.primary,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),

            // Explanations
            if (entity.aiExplanation != null)
              ExplanationCard(
                title: 'AI Analysis',
                explanation: entity.aiExplanation!,
                isAiGenerated: true,
              )
            else
              ExplanationCard(
                title: 'Heuristic Match',
                explanation: entity.offlineExplanation,
                isAiGenerated: false,
              ),

            const SizedBox(height: AppSpacing.s16),

            // Recommended Action
            if (entity.recommendedAction != null)
              RecommendationCard(recommendedAction: entity.recommendedAction!),

            const SizedBox(height: AppSpacing.s16),

            // Prevention Tips
            PreventionTipsCard(tips: entity.preventionTips),
          ],
        ),
      ),
    );
  }
}
