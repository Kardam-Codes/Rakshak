import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';

class PrivacyConsentDialog extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const PrivacyConsentDialog({
    super.key,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Privacy & Consent Notice'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Before enabling Trusted Family Mode, please review how your privacy is protected:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.s12),
            const Text('• Who receives alerts: Only trusted family contacts you explicitly add to your list.'),
            const SizedBox(height: 6),
            const Text('• When alerts are sent: Emergency emails are dispatched ONLY when HIGH or CRITICAL scam events occur and after you confirm or let the 10-second countdown finish.'),
            const SizedBox(height: 6),
            const Text('• What information is shared: The risk level, scam category, and safety advice. Passwords, PINs, and personal banking credentials are NEVER sent.'),
            const SizedBox(height: 6),
            const Text('• Local Storage: All contact details are stored locally on your device with encryption.'),
            const SizedBox(height: AppSpacing.s16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'By tapping "I Consent & Enable", you grant Rakshak permission to notify your chosen trusted contacts during emergency scam situations.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onDecline,
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondaryLight)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: onAccept,
          child: const Text('I Consent & Enable'),
        ),
      ],
    );
  }
}
