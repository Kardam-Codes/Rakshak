import 'package:flutter/material.dart';
import 'widgets/risk_summary_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_alerts.dart';
import 'widgets/safety_tip.dart';
import '../../core/constants/spacing.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Good Morning, User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {},
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: const [
          RiskSummaryCard(),
          SizedBox(height: AppSpacing.s24),
          QuickActions(),
          SizedBox(height: AppSpacing.s24),
          RecentAlerts(),
          SizedBox(height: AppSpacing.s24),
          SafetyTipCard(),
        ],
      ),
    );
  }
}
