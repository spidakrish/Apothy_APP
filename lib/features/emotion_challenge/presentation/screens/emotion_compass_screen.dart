import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/emotion.dart';
import '../widgets/emotion_wheel.dart';

/// Phase 1: The Emotional Compass
///
/// An interactive emotion exploration experience using Plutchik's Wheel.
/// Users can spin, zoom, and tap to select their current emotional state.
class EmotionCompassScreen extends StatefulWidget {
  const EmotionCompassScreen({super.key});

  @override
  State<EmotionCompassScreen> createState() => _EmotionCompassScreenState();
}

class _EmotionCompassScreenState extends State<EmotionCompassScreen>
    with TickerProviderStateMixin {
  // Selected emotion
  Emotion? _selectedEmotion;

  // Show secondary emotions toggle
  bool _showSecondaryEmotions = false;

  // Animation controllers
  late AnimationController _backgroundController;
  late AnimationController _entranceController;

  // Entrance animations
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _wheelFadeAnimation;
  late Animation<double> _wheelScaleAnimation;
  late Animation<double> _footerFadeAnimation;
  late Animation<Offset> _footerSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Background animation
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Entrance animations
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _setupEntranceAnimations();
    _entranceController.forward();
  }

  void _setupEntranceAnimations() {
    // Header fades in first
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Wheel fades and scales in
    _wheelFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.5, curve: Curves.easeOut),
      ),
    );

    _wheelScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOutBack),
      ),
    );

    // Footer slides up and fades in
    _footerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _footerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.75, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _onEmotionSelected(Emotion emotion) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedEmotion = emotion;
    });
  }

  void _toggleSecondaryEmotions() {
    HapticFeedback.lightImpact();
    setState(() {
      _showSecondaryEmotions = !_showSecondaryEmotions;
    });
  }

  void _proceedToNextPhase() {
    if (_selectedEmotion == null) {
      // Show hint to select emotion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select an emotion to continue',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    // Navigate to Phase 2 (Body Mapping)
    context.push(
      '/body-mapping',
      extra: {
        'emotion': _selectedEmotion,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated background
          _AnimatedBackground(animation: _backgroundController),

          // Main content
          SafeArea(
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (context, child) {
                return Column(
                  children: [
                    // Header
                    FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: _buildHeader(),
                    ),

                    // Wheel
                    Expanded(
                      child: FadeTransition(
                        opacity: _wheelFadeAnimation,
                        child: ScaleTransition(
                          scale: _wheelScaleAnimation,
                          child: _buildWheel(),
                        ),
                      ),
                    ),

                    // Footer
                    SlideTransition(
                      position: _footerSlideAnimation,
                      child: FadeTransition(
                        opacity: _footerFadeAnimation,
                        child: _buildFooter(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          // Back button and title row
          Row(
            children: [
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.pop();
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: Text(
                  'Emotional Compass',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Toggle for secondary emotions
              IconButton(
                onPressed: _toggleSecondaryEmotions,
                tooltip: _showSecondaryEmotions
                    ? 'Show primary emotions'
                    : 'Show all emotions',
                icon: Icon(
                  _showSecondaryEmotions
                      ? Icons.blur_circular
                      : Icons.blur_on,
                  color: _showSecondaryEmotions
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'How are you feeling right now?',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 4),

          // Instruction
          Text(
            'Spin the wheel or tap to select an emotion',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: EmotionWheel(
          selectedEmotion: _selectedEmotion,
          showSecondaryEmotions: _showSecondaryEmotions,
          onEmotionSelected: _onEmotionSelected,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected emotion info
          if (_selectedEmotion != null) ...[
            _buildEmotionInfo(),
            const SizedBox(height: 16),
          ],

          // Continue button
          AppButton(
            onPressed: _proceedToNextPhase,
            label: _selectedEmotion != null
                ? 'Continue with ${_selectedEmotion!.name}'
                : 'Select an emotion to continue',
            variant: _selectedEmotion != null
                ? AppButtonVariant.primary
                : AppButtonVariant.outlined,
            width: double.infinity,
          ),

          const SizedBox(height: 12),

          // Phase indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PhaseIndicator(phase: 1, isActive: true, label: 'Compass'),
              _PhaseConnector(),
              _PhaseIndicator(phase: 2, isActive: false, label: 'Body Map'),
              _PhaseConnector(),
              _PhaseIndicator(phase: 3, isActive: false, label: 'Scan'),
              _PhaseConnector(),
              _PhaseIndicator(phase: 4, isActive: false, label: 'Reframe'),
              _PhaseConnector(),
              _PhaseIndicator(phase: 5, isActive: false, label: 'Reflect'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionInfo() {
    final emotion = _selectedEmotion!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: emotion.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Emotion color indicator
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: emotion.color.withValues(alpha: 0.2),
              border: Border.all(color: emotion.color, width: 2),
            ),
            child: Center(
              child: Text(
                emotion.name[0].toUpperCase(),
                style: AppTypography.headlineSmall.copyWith(
                  color: emotion.color,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Emotion details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      emotion.name,
                      style: AppTypography.labelLarge.copyWith(
                        color: emotion.color,
                      ),
                    ),
                    if (emotion.intensity != EmotionIntensity.moderate) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: emotion.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          emotion.intensity.name,
                          style: AppTypography.labelSmall.copyWith(
                            color: emotion.color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  emotion.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Clear button
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedEmotion = null;
              });
            },
            icon: Icon(
              Icons.close,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

/// Phase indicator dot
class _PhaseIndicator extends StatelessWidget {
  const _PhaseIndicator({
    required this.phase,
    required this.isActive,
    required this.label,
  });

  final int phase;
  final bool isActive;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : AppColors.surface,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.borderSubtle,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '$phase',
              style: AppTypography.labelSmall.copyWith(
                color: isActive ? Colors.white : AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}

/// Connector line between phases
class _PhaseConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.borderSubtle,
    );
  }
}

/// Animated background with subtle particle effect
class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _BackgroundPainter(animation.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  _BackgroundPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw subtle radial gradients that drift
    for (int i = 0; i < 3; i++) {
      final phase = progress + (i * 0.33);
      final x = size.width * (0.3 + 0.4 * math.sin(phase * 2 * math.pi));
      final y = size.height * (0.3 + 0.4 * math.cos(phase * 2 * math.pi * 0.7));

      paint.shader = RadialGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(x, y), radius: size.width * 0.5),
      );

      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
