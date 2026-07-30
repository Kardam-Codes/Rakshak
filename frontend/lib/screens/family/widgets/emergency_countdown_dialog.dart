import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';

class EmergencyCountdownDialog extends StatefulWidget {
  final String userName;
  final String category;
  final String riskLevel;
  final int initialSeconds;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const EmergencyCountdownDialog({
    super.key,
    required this.userName,
    required this.category,
    required this.riskLevel,
    this.initialSeconds = 10,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<EmergencyCountdownDialog> createState() => _EmergencyCountdownDialogState();
}

class _EmergencyCountdownDialogState extends State<EmergencyCountdownDialog> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isHandled = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        if (!_isHandled) {
          _isHandled = true;
          Navigator.of(context).pop();
          widget.onConfirm();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleCancel() {
    if (_isHandled) return;
    _isHandled = true;
    _timer?.cancel();
    Navigator.of(context).pop();
    widget.onCancel();
  }

  void _handleConfirmNow() {
    if (_isHandled) return;
    _isHandled = true;
    _timer?.cancel();
    Navigator.of(context).pop();
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleCancel();
        return false;
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.danger, width: 2),
        ),
        backgroundColor: Colors.white,
        title: Column(
          children: [
            const Icon(Icons.gpp_maybe_rounded, size: 56, color: AppColors.danger),
            const SizedBox(height: 8),
            Text(
              'Notify Your Trusted Family?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.danger,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'A ${widget.riskLevel.toUpperCase()} risk scam event (${widget.category}) was detected.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: AppSpacing.s16),

            // Countdown Animated Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: _remainingSeconds / widget.initialSeconds,
                    strokeWidth: 8,
                    color: AppColors.danger,
                    backgroundColor: AppColors.danger.withOpacity(0.15),
                  ),
                ),
                Text(
                  '$_remainingSeconds',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.s16),
            const Text(
              'Rakshak will send an emergency alert email to your trusted contacts when the timer expires unless you cancel.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: _handleCancel,
            icon: const Icon(Icons.close),
            label: const Text('Cancel Alert'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: _handleConfirmNow,
            icon: const Icon(Icons.send_rounded),
            label: const Text('Notify Now'),
          ),
        ],
      ),
    );
  }
}
