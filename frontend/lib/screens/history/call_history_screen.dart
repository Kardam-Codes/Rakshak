import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../alerts/widgets/notification_card.dart'; // We can reuse RiskBadge
import '../../widgets/empty_state.dart';

class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History'),
      ),
      body: const EmptyState(
        message: 'No suspicious calls detected.\nYou are protected.',
        icon: Icons.security,
      ),
    );
  }
}
