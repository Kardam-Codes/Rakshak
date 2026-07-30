import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/call_entity.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/colors.dart';
import '../../widgets/risk_badge.dart';
import '../../engine/models/risk_level.dart';

class CallDetailScreen extends StatelessWidget {
  final CallEntity call;

  const CallDetailScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              call.contactName ?? call.phoneNumber,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.s8),
            Row(
              children: [
                RiskBadge(riskLevel: call.riskLevel),
                const SizedBox(width: AppSpacing.s8),
                Text("• ${call.callType.toUpperCase()}", style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: AppSpacing.s24),
            
            const Text("AI Analysis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.s8),
            Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: call.aiExplanation == null 
                  ? const Text("Waiting for AI backend analysis...")
                  : Text(call.aiExplanation!),
            ),
            
            const SizedBox(height: AppSpacing.s24),
            const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.s16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAction(context, Icons.block, "Block", AppColors.danger),
                _buildAction(context, Icons.report, "Report", AppColors.warning),
                _buildAction(context, Icons.phone, "Call Back", AppColors.success),
              ],
            ),
            if (call.riskLevel.index >= RiskLevel.medium.index) ... [
               const SizedBox(height: AppSpacing.s32),
               SizedBox(
                 width: double.infinity,
                 child: FilledButton.icon(
                    onPressed: () {
                       context.push('/emergency', extra: 'Suspicious Call Detected: ${call.phoneNumber} (${call.category.name})');
                    },
                    icon: const Icon(Icons.security),
                    label: const Text('Emergency Recovery Actions'),
                    style: FilledButton.styleFrom(
                       backgroundColor: Theme.of(context).colorScheme.error,
                       foregroundColor: Theme.of(context).colorScheme.onError,
                       padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                 ),
               ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildAction(BuildContext context, IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          radius: 24,
          child: Icon(icon),
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
