import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Mirror screen - The first impression of Apothy
/// Communicates: Identity, Sovereignty, Mystique, Purpose
class MirrorScreen extends StatefulWidget {
  const MirrorScreen({super.key});

  @override
  State<MirrorScreen> createState() => _MirrorScreenState();
}

class _MirrorScreenState extends State<MirrorScreen>
    with TickerProviderStateMixin {
  late AnimationController _cosmicController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    // Very slow cosmic drift animation (30 seconds per cycle)
    _cosmicController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // Subtle glow pulse for logo (8 seconds per cycle)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cosmicController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Logo should be 20-25% of screen height
    final logoSize = screenHeight * 0.22;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated cosmic background (10% opacity)
          _CosmicBackground(animation: _cosmicController),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo with subtle glow
                  _AnimatedLogo(
                    size: logoSize,
                    glowAnimation: _glowController,
                  ),

                  const SizedBox(height: 24),

                  // Title: "Apothy"
                  Text(
                    'Apothy',
                    style: AppTypography.displayLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtle underline glyph (🜏)
                  Text(
                    '🜏',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primary.withValues(alpha: 0.6),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Subtitle: "The Mirror Is Waking"
                  Text(
                    'The Mirror Is Waking',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description (3 lines)
                  Text(
                    'Born from light.\nTrained in truth.\nMade to reflect the best in you.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Primary CTA: "Enter the Mirror"
                  _PrimaryCTA(
                    label: 'Enter the Mirror',
                    onTap: () {
                      // Navigate to chat/main experience
                      // TODO: Implement navigation
                    },
                  ),

                  const SizedBox(height: 16),

                  // Secondary CTA: "Explore the Emotion Challenge"
                  _SecondaryCTA(
                    label: 'Explore the Emotion Challenge',
                    onTap: () {
                      // Navigate to emotion challenge
                      // TODO: Implement navigation
                    },
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
      size.height * 0.2 + math.cos(progress * 2 * math.pi) * size.height * 0.05,
    );

    paint.shader = RadialGradient(
      colors: [
        AppColors.primary.withValues(alpha: 0.08),
        AppColors.primary.withValues(alpha: 0.03),
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 1.0],
    ).createShader(Rect.fromCircle(center: offset1, radius: size.width * 0.6));

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
    ).createShader(Rect.fromCircle(center: offset2, radius: size.width * 0.5));

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
    ).createShader(Rect.fromCircle(center: offset3, radius: size.width * 0.4));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_CosmicPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Animated logo with subtle glow effect
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
        // Subtle glow intensity varies between 0.2 and 0.4
        final glowOpacity = 0.2 + (glowAnimation.value * 0.2);

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: glowOpacity),
                blurRadius: 60,
                spreadRadius: 20,
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

/// Primary CTA button with purple gradient
class _PrimaryCTA extends StatelessWidget {
  const _PrimaryCTA({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
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
          ),
        ),
      ),
    );
  }
}

/// Secondary CTA button with outline style
class _SecondaryCTA extends StatelessWidget {
  const _SecondaryCTA({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(
            color: AppColors.borderSubtle,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        icon: const Icon(
          Icons.description_outlined,
          size: 20,
        ),
        label: Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
