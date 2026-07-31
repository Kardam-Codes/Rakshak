import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';

class OtpSafetyCard extends StatelessWidget {
  const OtpSafetyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_rounded, color: AppColors.primary, size: 28),
              const SizedBox(width: AppSpacing.s12),
              Text(
                "Received an OTP?",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          _buildTipLine(Icons.check_circle_rounded, AppColors.success, "Enter it only in the app or website you personally opened."),
          _buildTipLine(Icons.check_circle_rounded, AppColors.success, "Make sure you requested this OTP."),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s8),
            child: Divider(),
          ),
          _buildTipLine(Icons.cancel_rounded, AppColors.danger, "Never tell it to someone calling you."),
          _buildTipLine(Icons.cancel_rounded, AppColors.danger, "Never send it on WhatsApp."),
          _buildTipLine(Icons.cancel_rounded, AppColors.danger, "Never forward the message."),
        ],
      ),
    );
  }

  Widget _buildTipLine(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
