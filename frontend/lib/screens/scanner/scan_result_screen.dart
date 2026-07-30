import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/scan_entity.dart';
import '../../engine/models/risk_level.dart';
import '../../engine/models/scam_category.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';

class ScanResultScreen extends StatelessWidget {
  final ScanResultEntity result;

  const ScanResultScreen({
    super.key,
    required this.result,
  });

  Color _getRiskColor(RiskLevel risk) {
    switch (risk) {
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

  IconData _getRiskIcon(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.safe:
        return Icons.verified_user_rounded;
      case RiskLevel.low:
        return Icons.info_rounded;
      case RiskLevel.medium:
        return Icons.warning_amber_rounded;
      case RiskLevel.high:
      case RiskLevel.critical:
        return Icons.gpp_bad_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor(result.riskLevel);
    final riskIcon = _getRiskIcon(result.riskLevel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Security Analysis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/scan'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Share.share(
                'Rakshak Scan Analysis:\nContent: ${result.content}\nRisk Level: ${result.riskLevel.name.toUpperCase()}\nAdvice: ${result.aiRecommendedAction ?? result.recommendedAction}',
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Risk Banner Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.s20),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: riskColor, width: 2),
              ),
              child: Column(
                children: [
                  Icon(riskIcon, size: 48, color: riskColor),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    'RISK LEVEL: ${result.riskLevel.name.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: riskColor,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Chip(
                    avatar: const Icon(Icons.category_outlined, size: 16),
                    label: Text(result.category.displayName),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  LinearProgressIndicator(
                    value: result.confidence,
                    backgroundColor: riskColor.withOpacity(0.2),
                    color: riskColor,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    'Confidence Score: ${(result.confidence * 100).toInt()}% (${result.processingTimeMs}ms)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s16),

            // 2. Scanned Content Preview Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppColors.dividerLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              result.scanType == ScanType.qr
                                  ? Icons.qr_code
                                  : result.scanType == ScanType.url
                                      ? Icons.link
                                      : Icons.image,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Scanned ${result.scanType.displayName}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: result.content));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Content copied to clipboard')),
                            );
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    SelectableText(
                      result.content,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.s16),

            // 3. AI Explanation Section
            if (result.aiSimpleExplanation != null) ...[
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.psychology_rounded, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'Rakshak AI Explanation',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text(
                        result.aiSimpleExplanation!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (result.aiReason != null) ...[
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          result.aiReason!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
            ],

            // 4. Offline Analysis & Matched Rules Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppColors.dividerLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.rule_folder_outlined, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Offline Rule Engine Analysis',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(result.offlineReason),
                    if (result.matchedRules.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.s12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: result.matchedRules
                            .map((rule) => Chip(
                                  label: Text(rule, style: const TextStyle(fontSize: 11)),
                                  backgroundColor: riskColor.withOpacity(0.1),
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.s16),

            // 5. Recommended Action Card
            Card(
              color: AppColors.primary.withOpacity(0.05),
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Recommended Action',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      result.aiRecommendedAction ?? result.recommendedAction,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.s24),

            // 6. Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: result.content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Content copied')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/scan'),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan Again'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
