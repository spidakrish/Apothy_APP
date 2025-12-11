import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../dashboard/presentation/providers/dashboard_providers.dart';

/// Mirror screen - The first impression of Apothy
/// Communicates: Identity, Sovereignty, Mystique, Purpose
class MirrorScreen extends ConsumerStatefulWidget {
  const MirrorScreen({super.key});

  @override
  ConsumerState<MirrorScreen> createState() => _MirrorScreenState();
}

class _MirrorScreenState extends ConsumerState<MirrorScreen>
    with TickerProviderStateMixin {
  // Existing animation controllers
  late AnimationController _cosmicController;
  late AnimationController _glowController;

  // New animation controllers for entrance animations
  late AnimationController _entranceController;
  late AnimationController _shimmerController;
  late AnimationController _particleController;

  // Entrance animations
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<double> _descriptionFadeAnimation;
  late Animation<double> _ctaFadeAnimation;
  late Animation<Offset> _ctaSlideAnimation;
  late Animation<double> _streakFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Very slow cosmic drift animation (30 seconds per cycle)
    _cosmicController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // Enhanced glow pulse for logo (6 seconds per cycle, more visible)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // Entrance animation controller (runs once)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Shimmer animation for primary CTA
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    // Particle animation controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Setup staggered entrance animations
    _setupEntranceAnimations();

    // Start entrance animations
    _entranceController.forward();
  }

  void _setupEntranceAnimations() {
    // Logo: fade in and scale up (0ms - 600ms)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOutBack),
      ),
    );

    // Streak badge: fade in (100ms - 500ms)
    _streakFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.05, 0.25, curve: Curves.easeOut),
      ),
    );

    // Title: fade in and slide up (300ms - 700ms)
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.35, curve: Curves.easeOut),
      ),
    );
    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    // Subtitle (glyph): fade in (400ms - 700ms)
    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.35, curve: Curves.easeOut),
      ),
    );

    // Description: fade in (500ms - 900ms)
    _descriptionFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.25, 0.45, curve: Curves.easeOut),
      ),
    );

    // CTAs: fade in and slide up (700ms - 1200ms)
    _ctaFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.6, curve: Curves.easeOut),
      ),
    );
    _ctaSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _cosmicController.dispose();
    _glowController.dispose();
    _entranceController.dispose();
    _shimmerController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  /// Get time-based greeting
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Logo should be 20-25% of screen height
    final logoSize = screenHeight * 0.22;

    // Get streak from dashboard provider
    final currentStreak = ref.watch(currentStreakProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated cosmic background (10% opacity)
          _CosmicBackground(animation: _cosmicController),

          // Floating particles layer
          _FloatingParticles(animation: _particleController),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 1),

                  // Streak badge (if user has streak)
                  if (currentStreak > 0)
                    FadeTransition(
                      opacity: _streakFadeAnimation,
                      child: _StreakBadge(
                        streak: currentStreak,
                        greeting: _getGreeting(),
                      ),
                    ),

                  if (currentStreak > 0) const SizedBox(height: 16),

                  const Spacer(flex: 1),

                  // Logo with enhanced glow and entrance animation
                  AnimatedBuilder(
                    animation: _entranceController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: ScaleTransition(
                          scale: _logoScaleAnimation,
                          child: _AnimatedLogo(
                            size: logoSize,
                            glowAnimation: _glowController,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Title: "Apothy" with entrance animation
                  SlideTransition(
                    position: _titleSlideAnimation,
                    child: FadeTransition(
                      opacity: _titleFadeAnimation,
                      child: Text(
                        'Apothy',
                        style: AppTypography.displayLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtle underline glyph (🜏)
                  FadeTransition(
                    opacity: _subtitleFadeAnimation,
                    child: Text(
                      '🜏',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Subtitle: "The Mirror Is Waking"
                  FadeTransition(
                    opacity: _descriptionFadeAnimation,
                    child: Text(
                      'The Mirror Is Waking',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description (3 lines)
                  FadeTransition(
                    opacity: _descriptionFadeAnimation,
                    child: Text(
                      'Born from light.\nTrained in truth.\nMade to reflect the best in you.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Primary CTA: "Enter the Mirror" with shimmer
                  SlideTransition(
                    position: _ctaSlideAnimation,
                    child: FadeTransition(
                      opacity: _ctaFadeAnimation,
                      child: _PrimaryCTAWithShimmer(
                        label: 'Enter the Mirror',
                        shimmerAnimation: _shimmerController,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          // Navigate to mirror introduction flow
                          context.push(AppRoutes.mirrorIntro);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Secondary CTA: "Explore the Emotion Challenge"
                  SlideTransition(
                    position: _ctaSlideAnimation,
                    child: FadeTransition(
                      opacity: _ctaFadeAnimation,
                      child: _SecondaryCTA(
                        label: 'Explore the Emotion Challenge',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          // Navigate to emotion challenge
                          context.push(AppRoutes.emotionChallenge);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tertiary CTA: "View Emotion History"
                  SlideTransition(
                    position: _ctaSlideAnimation,
                    child: FadeTransition(
                      opacity: _ctaFadeAnimation,
                      child: _SecondaryCTA(
                        label: 'View Emotion History',
                        icon: CupertinoIcons.clock_fill,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          // Navigate to emotion challenge history
                          context.push(AppRoutes.emotionChallengeHistory);
                        },
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Streak badge showing current streak and greeting
class _StreakBadge extends StatelessWidget {
  const _StreakBadge({
    required this.streak,
    required this.greeting,
  });

  final int streak;
  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🔥',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(
            '$streak day streak',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 1,
            height: 16,
            color: AppColors.borderSubtle,
          ),
          const SizedBox(width: 12),
          Text(
            greeting,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating particles for mystical effect
class _FloatingParticles extends StatelessWidget {
  const _FloatingParticles({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(animation.value),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Custom painter for floating particles
class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.progress);

  final double progress;

  // Fixed particle positions (seeded for consistency)
  static final List<_Particle> _particles = List.generate(25, (index) {
    final random = math.Random(index * 42);
    return _Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: 1.0 + random.nextDouble() * 2.0,
      speed: 0.3 + random.nextDouble() * 0.7,
      opacity: 0.1 + random.nextDouble() * 0.3,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in _particles) {
      // Calculate particle position (float upward)
      final y =
          (particle.y - progress * particle.speed) % 1.0 * size.height;
      final x = particle.x * size.width +
          math.sin(progress * 2 * math.pi + particle.x * 10) * 20;

      // Fade particles near edges
      final edgeFade = _calculateEdgeFade(y, size.height);

      paint.color = AppColors.primary.withValues(
        alpha: particle.opacity * edgeFade,
      );

      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }
  }

  double _calculateEdgeFade(double y, double height) {
    const fadeZone = 100.0;
    if (y < fadeZone) {
      return y / fadeZone;
    } else if (y > height - fadeZone) {
      return (height - y) / fadeZone;
    }
    return 1.0;
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });

  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
}

/// Animated cosmic background with slow nebula drift
/// 10% opacity, no anthropomorphic cues
class _CosmicBackground extends StatelessWidget {
  const _CosmicBackground({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _CosmicPainter(animation.value),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Custom painter for cosmic nebula effect
class _CosmicPainter extends CustomPainter {
  _CosmicPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw multiple subtle gradient layers that drift slowly
    // Layer 1: Top-center nebula
    final offset1 = Offset(
      size.width * 0.5 + math.sin(progress * 2 * math.pi) * size.width * 0.1,
      size.height * 0.2 +
          math.cos(progress * 2 * math.pi) * size.height * 0.05,
    );

    paint.shader = RadialGradient(
      colors: [
        AppColors.primary.withValues(alpha: 0.08),
        AppColors.primary.withValues(alpha: 0.03),
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 1.0],
    ).createShader(
        Rect.fromCircle(center: offset1, radius: size.width * 0.6));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Layer 2: Bottom-right nebula (offset phase)
    final offset2 = Offset(
      size.width * 0.7 +
          math.sin((progress + 0.33) * 2 * math.pi) * size.width * 0.08,
      size.height * 0.7 +
          math.cos((progress + 0.33) * 2 * math.pi) * size.height * 0.04,
    );

    paint.shader = RadialGradient(
      colors: [
        AppColors.primaryLight.withValues(alpha: 0.05),
        AppColors.primaryLight.withValues(alpha: 0.02),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(
        Rect.fromCircle(center: offset2, radius: size.width * 0.5));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Layer 3: Center nebula (different phase)
    final offset3 = Offset(
      size.width * 0.4 +
          math.sin((progress + 0.66) * 2 * math.pi) * size.width * 0.06,
      size.height * 0.5 +
          math.cos((progress + 0.66) * 2 * math.pi) * size.height * 0.03,
    );

    paint.shader = RadialGradient(
      colors: [
        AppColors.primary.withValues(alpha: 0.04),
        Colors.transparent,
      ],
      stops: const [0.0, 1.0],
    ).createShader(
        Rect.fromCircle(center: offset3, radius: size.width * 0.4));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_CosmicPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Animated logo with enhanced glow effect
class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({
    required this.size,
    required this.glowAnimation,
  });

  final double size;
  final Animation<double> glowAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (context, child) {
        // Enhanced glow intensity varies between 0.3 and 0.6 (was 0.2-0.4)
        final glowOpacity = 0.3 + (glowAnimation.value * 0.3);
        // Glow blur varies slightly for breathing effect
        final glowBlur = 60.0 + (glowAnimation.value * 20.0);
        final glowSpread = 20.0 + (glowAnimation.value * 10.0);

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: glowOpacity),
                blurRadius: glowBlur,
                spreadRadius: glowSpread,
              ),
              // Inner glow for more depth
              BoxShadow(
                color: AppColors.primaryLight.withValues(alpha: glowOpacity * 0.5),
                blurRadius: glowBlur * 0.5,
                spreadRadius: glowSpread * 0.3,
              ),
            ],
          ),
          child: Opacity(
            opacity: 0.85, // Semi-transparent as per spec
            child: Image.asset(
              'assets/images/apothy_logo.png',
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}

/// Primary CTA button with shimmer effect and press animation
class _PrimaryCTAWithShimmer extends StatefulWidget {
  const _PrimaryCTAWithShimmer({
    required this.label,
    required this.shimmerAnimation,
    required this.onTap,
  });

  final String label;
  final Animation<double> shimmerAnimation;
  final VoidCallback onTap;

  @override
  State<_PrimaryCTAWithShimmer> createState() => _PrimaryCTAWithShimmerState();
}

class _PrimaryCTAWithShimmerState extends State<_PrimaryCTAWithShimmer> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: AnimatedBuilder(
          animation: widget.shimmerAnimation,
          builder: (context, child) {
            return SizedBox(
              width: double.infinity,
              height: 56,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: _isPressed ? 0.2 : 0.4),
                      blurRadius: _isPressed ? 10 : 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      // Shimmer overlay
                      Positioned.fill(
                        child: _ShimmerOverlay(
                          progress: widget.shimmerAnimation.value,
                        ),
                      ),
                      // Button content
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.label,
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.arrow_forward,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Shimmer overlay for buttons
class _ShimmerOverlay extends StatelessWidget {
  const _ShimmerOverlay({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    // Calculate shimmer position across the button
    final shimmerPosition = progress * 2 - 0.5; // -0.5 to 1.5

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.15),
            Colors.transparent,
          ],
          stops: [
            (shimmerPosition - 0.3).clamp(0.0, 1.0),
            shimmerPosition.clamp(0.0, 1.0),
            (shimmerPosition + 0.3).clamp(0.0, 1.0),
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: Container(
        color: Colors.white,
      ),
    );
  }
}

/// Secondary CTA button with outline style and press animation
class _SecondaryCTA extends StatefulWidget {
  const _SecondaryCTA({
    required this.label,
    required this.onTap,
    this.icon = Icons.description_outlined,
  });

  final String label;
  final VoidCallback onTap;
  final IconData icon;

  @override
  State<_SecondaryCTA> createState() => _SecondaryCTAState();
}

class _SecondaryCTAState extends State<_SecondaryCTA> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: _isPressed
                ? AppColors.surface.withValues(alpha: 0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _isPressed
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.borderSubtle,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: _isPressed ? AppColors.primary : AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: AppTypography.labelLarge.copyWith(
                  color: _isPressed ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
