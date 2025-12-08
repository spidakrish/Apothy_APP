import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../services/haptic_service.dart';

/// Navigation shell widget that wraps all tab screens
/// Provides the bottom navigation bar and manages tab switching
/// Uses iOS-style tab bar following Apple HIG
class NavigationShell extends StatelessWidget {
  const NavigationShell({
    super.key,
    required this.navigationShell,
  });

  /// The stateful navigation shell from go_router
  final StatefulNavigationShell navigationShell;

  /// Handle tab selection with haptic feedback
  void _onDestinationSelected(int index) {
    // Haptic feedback for tab change (HIG recommendation)
    HapticService.tabChange();

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
      bottomNavigationBar: Platform.isIOS
          ? _buildIOSTabBar()
          : _buildAndroidNavigationBar(),
    );
  }

  /// iOS-style tab bar with blur effect following HIG
  Widget _buildIOSTabBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.navBarBackground.withValues(alpha: 0.8),
            border: const Border(
              top: BorderSide(
                color: AppColors.borderSubtle,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _IOSNavBarItem(
                    icon: CupertinoIcons.sparkles,
                    activeIcon: CupertinoIcons.sparkles,
                    label: 'Mirror',
                    isSelected: navigationShell.currentIndex == 0,
                    onTap: () => _onDestinationSelected(0),
                  ),
                  _IOSNavBarItem(
                    icon: CupertinoIcons.clock,
                    activeIcon: CupertinoIcons.clock_fill,
                    label: 'History',
                    isSelected: navigationShell.currentIndex == 1,
                    onTap: () => _onDestinationSelected(1),
                  ),
                  _IOSNavBarItem(
                    icon: CupertinoIcons.chat_bubble,
                    activeIcon: CupertinoIcons.chat_bubble_fill,
                    label: 'Chat',
                    isSelected: navigationShell.currentIndex == 2,
                    onTap: () => _onDestinationSelected(2),
                  ),
                  _IOSNavBarItem(
                    icon: CupertinoIcons.chart_bar,
                    activeIcon: CupertinoIcons.chart_bar_fill,
                    label: 'Dashboard',
                    isSelected: navigationShell.currentIndex == 3,
                    onTap: () => _onDestinationSelected(3),
                  ),
                  _IOSNavBarItem(
                    icon: CupertinoIcons.gear,
                    activeIcon: CupertinoIcons.gear_solid,
                    label: 'Settings',
                    isSelected: navigationShell.currentIndex == 4,
                    onTap: () => _onDestinationSelected(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Android Material Design navigation bar
  Widget _buildAndroidNavigationBar() {
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
        top: false,
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

/// iOS-style navigation bar item following Apple HIG
class _IOSNavBarItem extends StatelessWidget {
  const _IOSNavBarItem({
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
        // HIG: Minimum 44pt touch target
        width: 64,
        height: 50, // Taller for better touch target
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? AppColors.navBarActive
                  : AppColors.navBarInactive,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: null, // Uses SF Pro on iOS
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.navBarActive
                    : AppColors.navBarInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Material Design navigation bar item
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
        // HIG: Minimum 44pt touch target
        width: 64,
        height: 50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
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
