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
  String _number = "Unknown";
  String _reason = "Suspicious Call Detected";

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      // Assuming event is passed as a string or map. 
      // For now, doing a basic overlay update
      if (event != null && event is String) {
        setState(() {
          _reason = event;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
