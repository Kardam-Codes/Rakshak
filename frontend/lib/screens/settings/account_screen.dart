import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/icons.dart';
import '../../widgets/section_title.dart';
import '../../widgets/info_card.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.account_circle,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                Text(
                  'User',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  '+91 9876543210',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s32),
          
          const SectionTitle(title: 'Personal Information'),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email Address'),
            subtitle: const Text('user@example.com'),
            trailing: const Icon(Icons.edit, size: 20),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Rakshak ID'),
            subtitle: const Text('RK-1029384'),
            trailing: const Icon(Icons.copy, size: 20),
            onTap: () {},
          ),
          
          const Divider(height: AppSpacing.s32),
          
          const SectionTitle(title: 'Security'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Biometric Authentication'),
            trailing: Switch(
              value: true,
              onChanged: (val) {},
            ),
          ),
          
          const Divider(height: AppSpacing.s32),
          const SizedBox(height: AppSpacing.s16),
          
          Center(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout, color: AppColors.danger),
              label: const Text('Log Out', style: TextStyle(color: AppColors.danger)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s32, vertical: AppSpacing.s12),
              ),
            ),
          )
        ],
      ),
    );
  }
}
