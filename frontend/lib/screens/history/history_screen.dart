import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/scan_provider.dart';
import '../../providers/call_provider.dart';
import '../../providers/database_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_title.dart';
import '../../core/constants/icons.dart';
import '../../core/constants/spacing.dart';
import '../../widgets/call_card.dart';
import '../../engine/models/risk_level.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Calls'),
            Tab(text: 'Scans'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              if (_tabController.index == 0) {
                 ref.read(appDatabaseProvider).clearCalls();
              } else {
                 ref.read(appDatabaseProvider).clearScans();
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCallsTab(),
          _buildScansTab(),
        ],
      ),
    );
  }

  Widget _buildCallsTab() {
    final callsAsync = ref.watch(callsProvider);
    return callsAsync.when(
      data: (calls) {
        if (calls.isEmpty) {
          return const EmptyState(message: 'No call history yet.', icon: AppIcons.history);
        }
        return ListView.builder(
          itemCount: calls.length,
          itemBuilder: (context, index) {
            final call = calls[index];
            return CallCard(
              call: call,
              onTap: () => context.push('/history/call_detail', extra: call),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildScansTab() {
    final scansAsync = ref.watch(scanHistoryStreamProvider);
    return scansAsync.when(
      data: (scans) {
        if (scans.isEmpty) {
          return const EmptyState(message: 'No scan history yet.', icon: AppIcons.history);
        }
        return ListView.builder(
          itemCount: scans.length,
          itemBuilder: (context, index) {
            final scan = scans[index];
            return ListTile(
               leading: Icon(
                 scan.riskLevel == RiskLevel.safe ? Icons.check_circle : Icons.warning,
                 color: scan.riskLevel == RiskLevel.safe ? Colors.green : Colors.red,
               ),
               title: Text(scan.content, maxLines: 1, overflow: TextOverflow.ellipsis),
               subtitle: Text('${scan.category.name.toUpperCase()} • ${scan.timestamp.toString().substring(0, 16)}'),
               onTap: () => context.push('/scan/result', extra: scan),
               trailing: IconButton(
                 icon: const Icon(Icons.delete),
                 onPressed: () => ref.read(appDatabaseProvider).deleteScan(scan.id!),
               ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}
