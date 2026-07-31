import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/info_card.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/icons.dart';
import '../../widgets/section_title.dart';
import '../../providers/notification_provider.dart';

final _offlineAiToggleProvider = StateProvider<bool>((ref) => true);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionGranted = ref.watch(notificationPermissionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Alert History',
            onPressed: () => context.push('/history'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
        children: [
          // Security Engine Section
          const SectionTitle(title: 'Security Engine'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: Consumer(
              builder: (context, ref, child) {
                final isOfflineEngineActive = ref.watch(_offlineAiToggleProvider);
                return SwitchListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.s16),
                  title: const Text(
                    'Zero-Knowledge Offline AI', 
                    style: TextStyle(fontWeight: FontWeight.w600)
                  ),
                  subtitle: const Text(
                    'Live call protection. Audio is kept exclusively on-device and instantly deleted after 30s.',
                    style: TextStyle(height: 1.3),
                  ),
                  value: isOfflineEngineActive,
                  activeColor: Colors.white,
                  activeTrackColor: Colors.green[600],
                  secondary: CircleAvatar(
                    backgroundColor: isOfflineEngineActive ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
                    child: Icon(
                      isOfflineEngineActive ? Icons.shield : Icons.gpp_maybe,
                      color: isOfflineEngineActive ? Colors.green[700] : Colors.grey,
                    ),
                  ),
                  onChanged: (val) {
                    ref.read(_offlineAiToggleProvider.notifier).state = val;
                    if (val) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Offline Local Monitor Active! Cloud features disabled.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.s24),

          // Permissions Section
          const SectionTitle(title: 'System Permissions'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Notification Access', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(permissionGranted ? 'Granted' : 'Critical for SMS/UPI monitoring'),
                  trailing: permissionGranted
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : FilledButton.tonal(
                          onPressed: () {
                            ref.read(notificationPermissionProvider.notifier).requestPermission();
                          },
                          child: const Text('Request'),
                        ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.sync),
                  title: const Text('Sync Background Engine', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text('Restart threat listeners'),
                  trailing: OutlinedButton(
                    onPressed: () async {
                      final notifier = ref.read(notificationPermissionProvider.notifier);
                      await notifier.refreshListener();
                      final connected = await notifier.isServiceConnected();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(connected
                                ? 'Listener engines actively synced.'
                                : 'Sync warning: Toggle Notification Access off/on manually if issues persist.'),
                          ),
                        );
                      }
                    },
                    child: const Text('Refresh'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s24),

          // General & Info Section
          const SectionTitle(title: 'About App'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(16),
               side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: Column(
              children: const [
                InfoCard(
                  title: 'Language Profiles',
                  subtitle: 'English Models Active (Gujarati Offline Pack Pending)',
                  icon: AppIcons.info,
                ),
                Divider(height: 1),
                InfoCard(
                  title: 'Rakshak v1.0.0',
                  subtitle: 'Privacy-first Digital Banking AI',
                  icon: AppIcons.safe,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s32), // Bottom padding
        ],
      ),
    );
  }
}
