import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../providers/trusted_family_provider.dart';

class TrustedFamilyCard extends ConsumerWidget {
  const TrustedFamilyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(trustedContactsStreamProvider);
    final historyAsync = ref.watch(familyHistoryStreamProvider);
    final repository = ref.watch(trustedFamilyRepositoryProvider);

    final isEnabled = repository.isFeatureEnabled && repository.hasPrivacyConsent;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isEnabled ? AppColors.success.withOpacity(0.4) : AppColors.dividerLight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      color: isEnabled ? AppColors.success.withOpacity(0.04) : Colors.white,
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
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isEnabled
                          ? AppColors.success.withOpacity(0.15)
                          : AppColors.primary.withOpacity(0.15),
                      child: Icon(
                        Icons.family_restroom_rounded,
                        color: isEnabled ? AppColors.success : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Trusted Family Mode',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          isEnabled ? 'Emergency Network Active' : 'Setup Family Safety Shield',
                          style: TextStyle(
                            fontSize: 12,
                            color: isEnabled ? AppColors.success : AppColors.textSecondaryLight,
                            fontWeight: isEnabled ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => context.go('/family'),
                  child: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                Expanded(
                  child: contactsAsync.when(
                    data: (contacts) => _InfoBadge(
                      label: 'Contacts',
                      value: '${contacts.length}/5 Active',
                      icon: Icons.people_outline,
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: historyAsync.when(
                    data: (history) => _InfoBadge(
                      label: 'Last Alert',
                      value: history.isNotEmpty ? '${history.first.recipientName}' : 'None Sent',
                      icon: Icons.history_rounded,
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
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

class _InfoBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoBadge({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
                Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
