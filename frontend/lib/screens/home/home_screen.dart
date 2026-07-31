import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_alerts.dart';
import 'widgets/recent_scan_widget.dart';
import 'widgets/trusted_family_card.dart';
import 'widgets/safety_tip.dart';
import '../../core/constants/spacing.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rakshak', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              context.push('/settings/account');
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: const [
          QuickActions(),
          SizedBox(height: AppSpacing.s16),
          TrustedFamilyCard(),
          SizedBox(height: AppSpacing.s16),
          RecentScanWidget(),
          SizedBox(height: AppSpacing.s24),
          RecentAlerts(),
          SizedBox(height: AppSpacing.s24),
          SafetyTipCard(),
        ],
      ),
    );
  }
}
