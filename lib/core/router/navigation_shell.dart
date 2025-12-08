import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Navigation shell widget that wraps all tab screens
/// Provides the bottom navigation bar and manages tab switching
class NavigationShell extends StatelessWidget {
  const NavigationShell({
    super.key,
    required this.navigationShell,
  });

  /// The stateful navigation shell from go_router
  final StatefulNavigationShell navigationShell;

  /// Handle tab selection
  void _onDestinationSelected(int index) {
    // Navigate to the selected branch
    // If already on this tab, go to initial location (pop to root)
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBarBackground,
        border: Border(
          top: BorderSide(
            color: AppColors.borderSubtle,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.auto_awesome_outlined,
                activeIcon: Icons.auto_awesome,
                label: 'Mirror',
                isSelected: navigationShell.currentIndex == 0,
                onTap: () => _onDestinationSelected(0),
              ),
              _NavBarItem(
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                label: 'History',
                isSelected: navigationShell.currentIndex == 1,
                onTap: () => _onDestinationSelected(1),
              ),
              _NavBarItem(
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
                label: 'Chat',
                isSelected: navigationShell.currentIndex == 2,
                onTap: () => _onDestinationSelected(2),
              ),
              _NavBarItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Dashboard',
                isSelected: navigationShell.currentIndex == 3,
                onTap: () => _onDestinationSelected(3),
              ),
              _NavBarItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Settings',
                isSelected: navigationShell.currentIndex == 4,
                onTap: () => _onDestinationSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual navigation bar item
class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? AppColors.navBarActive
                  : AppColors.navBarInactive,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: isSelected
                  ? AppTypography.navLabelActive
                  : AppTypography.navLabel,
            ),
          ],
        ),
      ),
    );
  }
}
