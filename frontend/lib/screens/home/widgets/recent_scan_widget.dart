import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../engine/models/risk_level.dart';
import '../../../models/scan_entity.dart';
import '../../../providers/scan_provider.dart';

class RecentScanWidget extends ConsumerWidget {
  const RecentScanWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(scanHistoryStreamProvider);

    return historyAsync.when(
      data: (scans) {
        if (scans.isEmpty) return const SizedBox.shrink();
        final latest = scans.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Safe Scan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.go('/scan'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppColors.dividerLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: latest.riskLevel == RiskLevel.safe
                      ? AppColors.success.withOpacity(0.1)
                      : latest.riskLevel == RiskLevel.medium
                          ? AppColors.warning.withOpacity(0.1)
                          : AppColors.danger.withOpacity(0.1),
                  child: Icon(
                    latest.scanType == ScanType.qr
                        ? Icons.qr_code
                        : latest.scanType == ScanType.url
                            ? Icons.link
                            : Icons.image,
                    color: latest.riskLevel == RiskLevel.safe
                        ? AppColors.success
                        : latest.riskLevel == RiskLevel.medium
                            ? AppColors.warning
                            : AppColors.danger,
                    size: 20,
                  ),
                ),
                title: Text(
                  latest.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Last Risk: ${latest.riskLevel.name.toUpperCase()} • ${latest.scanType.displayName}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () => context.push('/scan/result', extra: latest),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
