import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/app_scaffold.dart';
import '../screens/home/home_screen.dart';
import '../screens/alerts/alerts_screen.dart';
import '../screens/scanner/scan_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../models/notification_entity.dart';
import '../models/call_entity.dart';
import '../models/upi_transaction_entity.dart';
import '../screens/alerts/explanation_detail_screen.dart';
import '../models/explanation_entity.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/alerts',
                builder: (context, state) => const AlertsScreen(),
                routes: [
                  GoRoute(
                    path: 'explain_detail',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      return ExplanationDetailScreen(
                        entity: extra['entity'] as ExplanationEntity,
                        contextTitle: extra['title'] as String,
                        contextSubtitle: extra['subtitle'] as String,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/scan',
                builder: (context, state) => const ScanScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(), // Switch to CallHistoryScreen if needed
                routes: [
                  GoRoute(
                    path: 'explain_detail',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      return ExplanationDetailScreen(
                        entity: extra['entity'] as ExplanationEntity,
                        contextTitle: extra['title'] as String,
                        contextSubtitle: extra['subtitle'] as String,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
