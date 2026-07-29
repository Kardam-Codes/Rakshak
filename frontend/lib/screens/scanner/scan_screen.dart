import 'package:flutter/material.dart';
import '../../widgets/empty_state.dart';
import '../../core/constants/icons.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Scan'),
      ),
      body: const EmptyState(
        message: 'Tap the button below to scan a QR code, link, or image for safety.',
        icon: AppIcons.scan,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(AppIcons.scan),
      ),
    );
  }
}
