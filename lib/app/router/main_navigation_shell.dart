
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

/// Shared bottom navigation for the five main marketplace tabs.
///
/// The active screen is provided by GoRouter's StatefulShellRoute.
class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({
    super.key,
    required this.navigationShell,
  });

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: Icon(
                Icons.home,
                color: AppColors.primary,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.search_outlined),
              selectedIcon: Icon(
                Icons.search,
                color: AppColors.primary,
              ),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.add_circle,
                color: AppColors.primary,
                size: 34,
              ),
              label: 'Sell',
            ),
            NavigationDestination(
              icon: const Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(
                Icons.chat_bubble,
                color: AppColors.primary,
              ),
              label: 'Messages',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: Icon(
                Icons.person,
                color: AppColors.primary,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
