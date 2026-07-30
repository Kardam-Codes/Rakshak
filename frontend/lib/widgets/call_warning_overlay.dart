import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/theme/app_theme.dart';

class CallWarningOverlay extends StatefulWidget {
  const CallWarningOverlay({super.key});

  @override
  State<CallWarningOverlay> createState() => _CallWarningOverlayState();
}

class _CallWarningOverlayState extends State<CallWarningOverlay> {
  String _reason = 'Suspicious event detected';
  bool _isOtp = false;

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event is! String) return;

      setState(() {
        _isOtp = event.startsWith('OTP:');
        _reason = _isOtp ? event.replaceFirst('OTP:', '').trim() : event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _CompactWarningOverlay(
      icon: _isOtp ? Icons.security_rounded : Icons.warning_rounded,
      title: _isOtp ? 'OTP Detected' : 'High Risk Call',
      message: _isOtp
          ? 'Never share OTPs. Banks and UPI apps will never ask for them.'
          : _reason,
      color: _isOtp ? AppColors.warning : AppColors.danger,
    );
  }
}

class _CompactWarningOverlay extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _CompactWarningOverlay({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.s16),
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close),
                  onPressed: FlutterOverlayWindow.closeOverlay,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@pragma('vm:entry-point')
void overlayMain() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const CallWarningOverlay(),
    ),
  );
}
