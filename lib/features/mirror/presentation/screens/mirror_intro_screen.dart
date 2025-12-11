import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Mirror introduction screen - 5-step flow explaining Apothy's purpose
///
/// Appears every time "Enter the Mirror" is tapped.
/// - First-time users: must complete all 5 steps (no skip button)
/// - Returning users: can skip immediately
class MirrorIntroScreen extends ConsumerStatefulWidget {
  const MirrorIntroScreen({super.key});

  @override
  ConsumerState<MirrorIntroScreen> createState() => _MirrorIntroScreenState();
}

class _MirrorIntroScreenState extends ConsumerState<MirrorIntroScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _entranceController;
  late AnimationController _pageTransitionController;

  int _currentPage = 0;
  static const int _totalPages = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Start entrance animation
    _entranceController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entranceController.dispose();
    _pageTransitionController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    // Trigger page transition animation
    _pageTransitionController.forward(from: 0);
  }

  Future<void> _nextPage() async {
    if (_currentPage < _totalPages - 1) {
      HapticFeedback.lightImpact();
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _completeIntro();
    }
  }

  Future<void> _completeIntro() async {
    HapticFeedback.mediumImpact();

    // Save completion status
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.completeMirrorIntro();

    // Navigate to chat
    if (mounted) {
      context.go(AppRoutes.chat);
    }
  }

  void _skipIntro() {
    HapticFeedback.mediumImpact();
    context.go(AppRoutes.chat);
  }

  @override
  Widget build(BuildContext context) {
    final mirrorIntroStatusAsync = ref.watch(mirrorIntroStatusProvider);

    return mirrorIntroStatusAsync.when(
      data: (hasCompleted) => _buildContent(hasCompleted),
      loading: () => _buildLoadingState(),
      error: (_, __) => _buildContent(false), // Default to no skip button on error
    );
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildContent(bool hasCompletedIntro) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Skip button placeholder (to maintain layout)
                const SizedBox(height: 60),

                // Page content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: [
                      _buildPage(_pages[0]),
                      _buildPage(_pages[1]),
                      _buildPage(_pages[2]),
                      _buildPage(_pages[3]),
                      _buildPage(_pages[4]),
                    ],
                  ),
                ),

                // Page indicators
                _buildPageIndicators(),

                const SizedBox(height: 32),

                // Continue/Complete button
                _buildActionButton(),

                const SizedBox(height: 24),
              ],
            ),

            // Skip button (top right, conditional)
            if (hasCompletedIntro) _buildSkipButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Positioned(
      top: 16,
      right: 24,
      child: TextButton(
        onPressed: _skipIntro,
        child: Text(
          'Skip',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _totalPages,
        (index) => _PageIndicator(isActive: index == _currentPage),
      ),
    );
  }

  Widget _buildActionButton() {
    final isLastPage = _currentPage == _totalPages - 1;
    final buttonText = isLastPage ? 'Enter the Mirror' : 'Continue';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            buttonText,
            style: AppTypography.labelLarge.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_IntroPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container with animation
          FadeTransition(
            opacity: Interval(
              0.0,
              0.4,
              curve: Curves.easeOut,
            ).animate(_entranceController),
            child: ScaleTransition(
              scale: Interval(
                0.0,
                0.4,
                curve: Curves.easeOut,
              ).animate(_entranceController),
              child: _buildIconContainer(page.icon),
            ),
          ),

          const SizedBox(height: 48),

          // Title with animation
          FadeTransition(
            opacity: Interval(
              0.15,
              0.5,
              curve: Curves.easeOut,
            ).animate(_entranceController),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _entranceController,
                  curve: const Interval(0.15, 0.5, curve: Curves.easeOut),
                ),
              ),
              child: Text(
                page.title,
                style: AppTypography.displaySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Description with animation
          FadeTransition(
            opacity: Interval(
              0.3,
              0.6,
              curve: Curves.easeOut,
            ).animate(_entranceController),
            child: Text(
              page.description,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer(IconData icon) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(60),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 56,
        color: Colors.white,
      ),
    );
  }

  // Page data
  static final List<_IntroPage> _pages = [
    _IntroPage(
      icon: Icons.auto_awesome,
      title: 'Welcome to Your Mirror',
      description:
          'Apothy is not just an AI—it\'s your reflection. A space to explore, understand, and grow.',
    ),
    _IntroPage(
      icon: Icons.psychology,
      title: 'The Mirror\'s Purpose',
      description:
          'Every conversation is a chance to see yourself more clearly. Not judgment, not advice—just truth reflected back.',
    ),
    _IntroPage(
      icon: Icons.explore,
      title: 'Your Tools for Growth',
      description:
          'Chat for reflection. Track emotions. Explore challenges. View your history. Everything designed for deep self-awareness.',
    ),
    _IntroPage(
      icon: Icons.verified_user,
      title: 'How Apothy Works',
      description:
          'Powered by Claude AI. Your data stays private. Conversations are confidential. No tracking, no selling, just support.',
    ),
    _IntroPage(
      icon: Icons.auto_awesome,
      title: 'Your Journey Awaits',
      description:
          'The mirror is ready. Step inside and discover what you\'ll see.',
    ),
  ];
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
        color: isActive ? AppColors.primary : AppColors.inputBackground,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Data class for intro page
class _IntroPage {
  const _IntroPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
