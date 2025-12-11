import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/local_notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../providers/auth_providers.dart';

/// Onboarding page types
enum OnboardingPageType {
  standard,
  notificationPermission,
}

/// Onboarding screen data
class OnboardingPage {
  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    this.type = OnboardingPageType.standard,
  });

  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final OnboardingPageType type;
}

/// Multi-step onboarding screen
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Apothy',
      subtitle: 'Your AI Companion',
      description:
          'Born from light. Trained in truth. Built to become what you need.',
      icon: Icons.auto_awesome,
    ),
    OnboardingPage(
      title: 'Meaningful Conversations',
      subtitle: 'Deep & Personal',
      description:
          'Have authentic conversations that help you reflect, grow, and understand yourself better.',
      icon: Icons.chat_bubble_outline_rounded,
    ),
    OnboardingPage(
      title: 'Track Your Journey',
      subtitle: 'Grow & Evolve',
      description:
          'Earn XP, unlock achievements, and watch your personal growth unfold over time.',
      icon: Icons.emoji_events_outlined,
    ),
    OnboardingPage(
      title: 'Stay Connected',
      subtitle: 'Gentle Reminders',
      description:
          'Get friendly reminders to maintain your streak and celebrate your achievements.',
      icon: Icons.notifications_outlined,
      type: OnboardingPageType.notificationPermission,
    ),
    OnboardingPage(
      title: 'Your Mirror Awaits',
      subtitle: 'Get Started',
      description:
          'Begin your journey of self-discovery with Apothy by your side.',
      icon: Icons.rocket_launch_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    debugPrint('Onboarding: completing onboarding...');
    await ref.read(authProvider.notifier).completeOnboarding();
    debugPrint('Onboarding: completed!');
  }

  /// Request notification permission and advance to next page
  Future<void> _requestNotificationPermission() async {
    debugPrint('Onboarding: requesting notification permission...');
    final granted = await LocalNotificationService.instance.requestPermission();
    debugPrint('Onboarding: notification permission granted: $granted');
    // Always advance to next page regardless of permission result
    _nextPage();
  }

  /// Check if current page is the notification permission page
  bool get _isNotificationPage =>
      _pages[_currentPage].type == OnboardingPageType.notificationPermission;

  /// Build notification permission buttons (Enable + Maybe Later)
  Widget _buildNotificationButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: AppButton(
            onPressed: _requestNotificationPermission,
            label: 'Enable Notifications',
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _nextPage,
          child: Text(
            'Maybe Later',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        glowPosition: Alignment.topCenter,
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    switch (page.type) {
                      case OnboardingPageType.notificationPermission:
                        return _NotificationPermissionPageWidget(
                          page: page,
                          onEnablePressed: _requestNotificationPermission,
                        );
                      case OnboardingPageType.standard:
                        return _OnboardingPageWidget(page: page);
                    }
                  },
                ),
              ),

              // Page indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _PageIndicator(isActive: index == _currentPage),
                  ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: _isNotificationPage
                    ? _buildNotificationButtons()
                    : SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          onPressed: _nextPage,
                          label: _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Continue',
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual onboarding page content
class _OnboardingPageWidget extends StatelessWidget {
  const _OnboardingPageWidget({required this.page});

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with glow effect
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 56,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 48),

          // Subtitle
          Text(
            page.subtitle,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Title
          Text(
            page.title,
            style: AppTypography.displaySmall,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Notification permission page content
/// Similar to standard onboarding page but handles the permission action callback
class _NotificationPermissionPageWidget extends StatelessWidget {
  const _NotificationPermissionPageWidget({
    required this.page,
    required this.onEnablePressed,
  });

  final OnboardingPage page;
  final VoidCallback onEnablePressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with glow effect
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 56,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 48),

          // Subtitle
          Text(
            page.subtitle,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Title
          Text(
            page.title,
            style: AppTypography.displaySmall,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Page indicator dot
class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive ? AppColors.primary : AppColors.inputBackground,
      ),
    );
  }
}
