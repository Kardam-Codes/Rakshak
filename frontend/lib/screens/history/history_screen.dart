import 'package:flutter/material.dart';
import '../../widgets/empty_state.dart';
import '../../core/constants/icons.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: const EmptyState(
        message: 'No scanning history yet.',
        icon: AppIcons.history,
      ),
    );
  }
}
