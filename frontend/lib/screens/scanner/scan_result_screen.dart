import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../models/scan_entity.dart';
import '../../engine/models/risk_level.dart';
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
        return Icons.check_circle_rounded;
      case RiskLevel.low:
        return Icons.info_rounded;
      case RiskLevel.medium:
        return Icons.warning_rounded;
      case RiskLevel.high:
      case RiskLevel.critical:
        return Icons.cancel_rounded;
    }
  }

  String _getRiskTitle(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.safe:
        return 'SAFE';
      case RiskLevel.low:
        return 'LOW RISK';
      case RiskLevel.medium:
        return 'SUSPICIOUS';
      case RiskLevel.high:
      case RiskLevel.critical:
        return 'DANGEROUS';
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor(result.riskLevel);
    final riskIcon = _getRiskIcon(result.riskLevel);
    final isSafe = result.riskLevel == RiskLevel.safe;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/scan'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Centerpiece: Large Icon & Status
            Column(
              children: [
                Icon(riskIcon, size: 80, color: riskColor),
                const SizedBox(height: AppSpacing.s16),
                Text(
                  _getRiskTitle(result.riskLevel),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.s32),

            // AI Explanation Centerpiece
            Container(
              padding: const EdgeInsets.all(AppSpacing.s24),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: riskColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSafe) ...[
                    const Text(
                      'No suspicious patterns detected.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    const Text('This scanned content appears safe based on our checks. You can continue if you trust the source.'),
                  ] else ...[
                    Text(
                      'Why did Rakshak warn you?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    if (result.aiSimpleExplanation != null) ...[
                      Text(
                        result.aiSimpleExplanation!,
                        style: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                    ],
                    Text(
                      result.aiReason ?? result.offlineReason,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ],
              ),
            ),
            
            if (!isSafe) ...[
              const SizedBox(height: AppSpacing.s24),
              // Recommended Action
              Container(
                padding: const EdgeInsets.all(AppSpacing.s20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.dividerLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Recommended Action',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Text(
                      result.aiRecommendedAction ?? result.recommendedAction,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.s32),
            
            // Actions
            if (result.riskLevel == RiskLevel.safe) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    context.go('/scan');
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ] else if (result.riskLevel == RiskLevel.medium) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Matched Rules'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: result.matchedRules
                                  .map((r) => Text('• $r'))
                                  .toList(),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
                            ],
                          ),
                        );
                      },
                      child: const Text('Learn Why'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => context.go('/scan'),
                      child: const Text('Go Back'),
                    ),
                  ),
                ],
              )
            ] else ...[
              // Dangerous
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: riskColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => context.go('/scan'),
                  child: const Text('Got it', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Scan removed from history')),
                        );
                        context.go('/scan');
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reported successfully to Rakshak')),
                        );
                      },
                      icon: const Icon(Icons.report_outlined),
                      label: const Text('Report'),
                    ),
                  ),
                ],
              )
            ],
          ],
        ),
      ),
    );
  }
}
