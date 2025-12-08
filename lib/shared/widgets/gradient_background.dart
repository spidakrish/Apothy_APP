import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Background widget with purple glow effect matching Apothy design
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.showGlow = true,
    this.glowPosition = Alignment.topCenter,
    this.glowIntensity = 0.3,
  });

  /// Child widget to display on top of the background
  final Widget child;

  /// Whether to show the purple glow effect
  final bool showGlow;

  /// Position of the glow effect
  final Alignment glowPosition;

  /// Intensity of the glow (0.0 to 1.0)
  final double glowIntensity;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Stack(
        children: [
          if (showGlow) _buildGlow(),
          child,
        ],
      ),
    );
  }

  Widget _buildGlow() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: glowPosition,
            radius: 1.2,
            colors: [
              AppColors.primary.withValues(alpha: glowIntensity),
              AppColors.primary.withValues(alpha: glowIntensity * 0.5),
              AppColors.background.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Animated gradient background with subtle pulsing effect
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.animationDuration = const Duration(seconds: 4),
  });

  /// Child widget to display on top of the background
  final Widget child;

  /// Duration of one animation cycle
  final Duration animationDuration;

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _animation = Tween<double>(
      begin: 0.15,
      end: 0.35,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GradientBackground(
          glowIntensity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}
