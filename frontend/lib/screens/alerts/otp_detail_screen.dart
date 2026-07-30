import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/notification_entity.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../engine/models/risk_level.dart';
import '../../widgets/safety_tips_card.dart';
import '../../widgets/otp_safety_card.dart';

class OtpDetailScreen extends StatelessWidget {
  final NotificationEntity notification;

  const OtpDetailScreen({super.key, required this.notification});

  void _handleCopy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: notification.body));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('You copied an OTP'),
        content: const Text(
            'Only paste it into the official app or website you opened.\n\nNever paste it into links sent by strangers.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _handleShare(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure you want to share this OTP?'),
        content: const Text(
            'Sharing your OTP may allow someone else to access your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Share.share(notification.body, subject: 'OTP message');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            child: const Text('Continue Anyway'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _handleShare(context),
            tooltip: 'Share',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Safe/High Risk Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Text(
                      'Message from ${notification.appName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),

            // OTP Message Content
            Card(
              elevation: 0,
              color: AppColors.surfaceLight,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: AppColors.textSecondary.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Received: ${DateFormat('MMM d, h:mm a').format(notification.timestamp)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Text(
                      notification.body,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('Copy Text'),
                        onPressed: () => _handleCopy(context),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s24),

            // AI Explanation
            if (notification.aiSimpleExplanation != null) ...[
              const Text('Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: AppSpacing.s12),
              Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.aiSimpleExplanation!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    if (notification.aiReason != null)
                      Text(notification.aiReason!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
            ],

            const OtpSafetyCard(),
            const SizedBox(height: AppSpacing.s24),

            SafetyTipsCard(
              tips: const [
                "Never share OTPs.",
                "Banks never ask for OTPs over phone or chat.",
                "Do not read OTPs aloud during calls.",
                "Do not forward OTP messages manually.",
                "Ignore people creating false urgency.",
                "If unsure, contact your bank directly.",
              ],
            ),
          ],
        ),
      ),
    );
  }
}
