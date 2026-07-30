import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';

class CallWarningOverlay extends StatefulWidget {
  const CallWarningOverlay({super.key});

  @override
  State<CallWarningOverlay> createState() => _CallWarningOverlayState();
}

class _CallWarningOverlayState extends State<CallWarningOverlay> {
  String _reason = "Suspicious Event Detected";
  bool _isOtp = false;

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event != null && event is String) {
        setState(() {
          if (event.startsWith('OTP:')) {
            _isOtp = true;
            _reason = event.replaceFirst('OTP:', '').trim();
          } else {
            _isOtp = false;
            _reason = event;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isOtp) {
      return _buildOtpOverlay(context);
    }
    return _buildCallOverlay(context);
  }

  Widget _buildOtpOverlay(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.s16),
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: AppColors.warning, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security_rounded, color: AppColors.warning, size: 32),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Text(
                    "OTP Detected",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              "⚠ Never share this OTP with anyone.\nBanks, UPI apps and government agencies will never ask for your OTP through a phone call, SMS, WhatsApp or social media.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                 OutlinedButton(
                   onPressed: () {
                     FlutterOverlayWindow.closeOverlay();
                   },
                   child: const Text("Dismiss"),
                 ),
                 ElevatedButton(
                   onPressed: () {
                     // Since overlay isolate cannot easily push routes, we just close and expect user to open app
                     FlutterOverlayWindow.closeOverlay();
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: AppColors.primary,
                     foregroundColor: Colors.white,
                   ),
                   child: const Text("View Details"),
                 )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCallOverlay(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.s16),
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: AppColors.danger, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_rounded, color: AppColors.danger, size: 32),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Text(
                    "High Risk Call",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    FlutterOverlayWindow.closeOverlay();
                  },
                )
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              _reason,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.s16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                 ElevatedButton(
                   onPressed: () {
                     FlutterOverlayWindow.closeOverlay();
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: AppColors.danger,
                     foregroundColor: Colors.white,
                   ),
                   child: const Text("Dismiss"),
                 )
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Global entry point required by flutter_overlay_window
@pragma("vm:entry-point")
void overlayMain() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const CallWarningOverlay(),
    ),
  );
}
