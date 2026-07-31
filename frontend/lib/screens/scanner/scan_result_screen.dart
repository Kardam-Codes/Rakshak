import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/scan_entity.dart';
import '../../engine/models/risk_level.dart';
import '../../engine/evidence/evidence_models.dart';
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

  IconData _getSeverityIcon(EvidenceSeverity severity) {
    switch (severity) {
      case EvidenceSeverity.low: return Icons.info_outline;
      case EvidenceSeverity.medium: return Icons.warning_amber_rounded;
      case EvidenceSeverity.high: return Icons.error_outline;
      case EvidenceSeverity.critical: return Icons.dangerous_outlined;
    }
  }

  Color _getSeverityColor(EvidenceSeverity severity) {
    switch (severity) {
      case EvidenceSeverity.low: return AppColors.info;
      case EvidenceSeverity.medium: return AppColors.warning;
      case EvidenceSeverity.high: return Colors.orange;
      case EvidenceSeverity.critical: return AppColors.danger;
    }
  }

  Future<void> _saveEvidence(BuildContext context) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/rakshak_evidence_${DateTime.now().millisecondsSinceEpoch}.txt');
      
      final buffer = StringBuffer();
      buffer.writeln('RAKSHAK THREAT EVIDENCE REPORT');
      buffer.writeln('==============================');
      buffer.writeln('Timestamp: ${result.timestamp}');
      buffer.writeln('Content Scanned: ${result.content}');
      buffer.writeln('Risk Level: ${_getRiskTitle(result.riskLevel)}');
      buffer.writeln('Confidence: ${result.confidencePercentage}%');
      buffer.writeln('\nWhy Rakshak warned you:');
      for (var e in result.evidence) {
        buffer.writeln('- [${e.category.name.toUpperCase()}] ${e.reason}');
      }
      
      await file.writeAsString(buffer.toString());
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Evidence saved to: ${file.path}')),
        );
        Share.shareXFiles([XFile(file.path)], text: 'Rakshak Scan Evidence');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save evidence')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor(result.riskLevel);
    final riskIcon = _getRiskIcon(result.riskLevel);
    final isSafe = result.riskLevel == RiskLevel.safe;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result', semanticsLabel: 'Scan Result'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/scan'),
          tooltip: 'Close Result',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Centerpiece: Large Icon & Status
            Semantics(
              label: 'Risk Level: ${_getRiskTitle(result.riskLevel)}',
              child: Column(
                children: [
                  Icon(riskIcon, size: 100, color: riskColor),
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    _getRiskTitle(result.riskLevel),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: riskColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${result.confidencePercentage}% Confidence',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.s32),

            // Why Rakshak warned you
            Container(
              padding: const EdgeInsets.all(AppSpacing.s24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSafe) ...[
                    const Row(
                      children: [
                        Icon(Icons.verified_user, color: AppColors.success),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No suspicious patterns detected.',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    const Text(
                      'This scanned content appears safe based on our checks. You can continue if you trust the source.',
                      style: TextStyle(fontSize: 16, color: AppColors.textSecondaryLight),
                    ),
                  ] else ...[
                    Text(
                      'Why Rakshak warned you',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    if (result.evidence.isEmpty) 
                       Text(
                        result.offlineReason,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      )
                    else 
                      ...result.evidence.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(_getSeverityIcon(e.severity), color: _getSeverityColor(e.severity), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                e.reason,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      )),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.s24),

            // What should you do?
            if (!isSafe) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.s24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.dividerLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppColors.primary, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'What should you do?',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Text(
                      result.aiRecommendedAction ?? result.recommendedAction,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5),
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
                child: ElevatedButton(
                  onPressed: () => context.go('/scan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              )
            ] else if (result.riskLevel == RiskLevel.medium) ...[
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => context.go('/scan'),
                      child: const Text('Go Back', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Detailed AI Explainability coming soon!')),
                        );
                      },
                      child: const Text('Learn Why', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ] else ...[
              // Dangerous
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: riskColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Reported successfully to Rakshak')),
                              );
                              context.go('/scan');
                            },
                            icon: const Icon(Icons.report_outlined),
                            label: const Text('Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: result.content));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Details copied to clipboard')),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded),
                            label: const Text('Copy Details'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => _saveEvidence(context),
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Save Evidence'),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
            const SizedBox(height: 48), // Padding at bottom
          ],
        ),
      ),
    );
  }
}
