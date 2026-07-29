import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/icons.dart';
import '../core/constants/strings.dart';

class AppScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({super.key, required this.navigationShell});

  void _onItemTapped(int index, BuildContext context) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(icon: Icon(AppIcons.home), label: AppStrings.home),
          BottomNavigationBarItem(icon: Icon(AppIcons.alerts), label: AppStrings.alerts),
          BottomNavigationBarItem(icon: Icon(AppIcons.scan), label: AppStrings.scan),
          BottomNavigationBarItem(icon: Icon(AppIcons.history), label: AppStrings.history),
          BottomNavigationBarItem(icon: Icon(AppIcons.settings), label: AppStrings.settings),
        ],
      ),
    );
  }
}
