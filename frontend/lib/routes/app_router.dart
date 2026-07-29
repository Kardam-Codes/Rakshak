import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/app_scaffold.dart';
import '../screens/home/home_screen.dart';
import '../screens/alerts/alerts_screen.dart';
import '../screens/scanner/scan_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/alerts/notification_detail_screen.dart';
import '../models/notification_entity.dart';
import '../screens/history/call_detail_screen.dart';
import '../models/call_entity.dart';

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
                    path: 'notification_detail',
                    builder: (context, state) {
                      final notification = state.extra as NotificationEntity;
                      return NotificationDetailScreen(notification: notification);
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
                    path: 'call_detail',
                    builder: (context, state) {
                      final call = state.extra as CallEntity;
                      return CallDetailScreen(call: call);
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
