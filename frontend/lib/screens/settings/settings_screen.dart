import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/info_card.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/icons.dart';
import '../../widgets/section_title.dart';
import '../../providers/notification_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionGranted = ref.watch(notificationPermissionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/history'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [
          const SectionTitle(title: 'Permissions'),
          ListTile(
            title: const Text('Notification Access'),
            subtitle: Text(permissionGranted ? 'Granted' : 'Denied'),
            trailing: permissionGranted 
                ? const Icon(Icons.check_circle, color: Colors.green)
                : OutlinedButton(
                    onPressed: () {
                      ref.read(notificationPermissionProvider.notifier).requestPermission();
                    },
                    child: const Text('Request'),
                  ),
          ),
          ListTile(
            title: const Text('Notification Listener'),
            subtitle: const Text('Restart listener and resync active notifications'),
            trailing: OutlinedButton(
              onPressed: () async {
                final notifier = ref.read(notificationPermissionProvider.notifier);
                await notifier.refreshListener();
                final connected = await notifier.isServiceConnected();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        connected
                            ? 'Notification listener is connected.'
                            : 'Listener refreshed. Toggle Notification Access off/on if it still stays disconnected.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Refresh'),
            ),
          ),
          const Divider(),
          const SectionTitle(title: 'General'),
          const InfoCard(
            title: 'Language',
            subtitle: 'English (Gujarati coming soon)',
            icon: AppIcons.info,
          ),
          const SizedBox(height: AppSpacing.s16),
          const SectionTitle(title: 'App Info'),
          const InfoCard(
            title: 'Rakshak',
            subtitle: 'Your AI Companion for Safe Digital Banking.\nVersion 1.0',
            icon: AppIcons.safe,
          ),
        ],
      ),
    );
  }
}
