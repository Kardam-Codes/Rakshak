import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/colors.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.s16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ActionIcon(
              icon: Icons.qr_code_scanner,
              label: 'Scan QR',
              onTap: () => context.go('/scan'),
            ),
            _ActionIcon(
              icon: Icons.link,
              label: 'Check Link',
              onTap: () => context.go('/scan'),
            ),
            _ActionIcon(
              icon: Icons.image,
              label: 'Upload Image',
              onTap: () => context.go('/scan'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
