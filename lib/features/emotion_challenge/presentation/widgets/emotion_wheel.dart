import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/emotion.dart';

/// Interactive Plutchik's Wheel of Emotions
///
/// Features:
/// - 8 primary emotions as colored wedges
/// - 8 secondary emotions between primaries (shown on expansion)
/// - 3 intensity rings (outer = mild, middle = moderate, inner = intense)
/// - Rotation gesture to spin the wheel
/// - Tap to select emotions
/// - Glow effect on selected emotion
/// - Smooth animations throughout
class EmotionWheel extends StatefulWidget {
  const EmotionWheel({
    super.key,
    this.onEmotionSelected,
    this.selectedEmotion,
    this.showSecondaryEmotions = false,
    this.size,
  });

  /// Callback when an emotion is selected
  final ValueChanged<Emotion>? onEmotionSelected;

  /// Currently selected emotion
  final Emotion? selectedEmotion;

  /// Whether to show secondary emotions between primaries
  final bool showSecondaryEmotions;

  /// Size of the wheel (defaults to fit container)
  final double? size;

  @override
  State<EmotionWheel> createState() => _EmotionWheelState();
}

class _EmotionWheelState extends State<EmotionWheel>
    with TickerProviderStateMixin {
  // Rotation state
  double _rotation = 0.0;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _selectionController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _selectionAnimation;

  // Selected intensity ring (0 = outer/mild, 1 = middle/moderate, 2 = inner/intense)
  int _selectedRing = 1; // Default to moderate

  // Hover/touch state
  Emotion? _hoveredEmotion;

  @override
  void initState() {
    super.initState();

    // Subtle pulse animation for the wheel
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Selection glow animation
    _selectionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _selectionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _selectionController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _selectionController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(EmotionWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedEmotion != oldWidget.selectedEmotion) {
      if (widget.selectedEmotion != null) {
        _selectionController.forward(from: 0.0);
      } else {
        _selectionController.reverse();
      }
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final touchPoint = details.localPosition;

    // Calculate angle from center to touch point
    final angle = math.atan2(
      touchPoint.dy - center.dy,
      touchPoint.dx - center.dx,
    );

    // Calculate previous angle
    final previousPoint = touchPoint - details.delta;
    final previousAngle = math.atan2(
      previousPoint.dy - center.dy,
      previousPoint.dx - center.dx,
    );

    // Update rotation
    setState(() {
      _rotation += angle - previousAngle;
    });
  }

  void _handleTapUp(TapUpDetails details, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final touchPoint = details.localPosition;
    final radius = size.width / 2;

    // Calculate distance from center
    final distance = (touchPoint - center).distance;

    // Determine which ring was tapped
    final outerRadius = radius * 0.95;
    final middleRadius = radius * 0.70;
    final innerRadius = radius * 0.45;
    final centerRadius = radius * 0.20;

    if (distance < centerRadius) {
      // Tapped center - could show all emotions or reset
      return;
    }

    // Determine ring
    int ring;
    if (distance < innerRadius) {
      ring = 2; // Intense
    } else if (distance < middleRadius) {
      ring = 1; // Moderate
    } else if (distance < outerRadius) {
      ring = 0; // Mild
    } else {
      return; // Outside wheel
    }

    // Calculate angle from center (adjusted for rotation)
    double angle = math.atan2(
          touchPoint.dy - center.dy,
          touchPoint.dx - center.dx,
        ) -
        _rotation;

    // Convert to degrees and normalize to 0-360
    double degrees = (angle * 180 / math.pi + 90) % 360;
    if (degrees < 0) degrees += 360;

    // Find the emotion at this angle
    final emotions = widget.showSecondaryEmotions
        ? PlutchikEmotions.allEmotions
        : PlutchikEmotions.primaryEmotions;

    final segmentSize = 360.0 / emotions.length;

    for (final emotion in emotions) {
      final emotionStart = (emotion.angle - segmentSize / 2 + 360) % 360;
      final emotionEnd = (emotion.angle + segmentSize / 2) % 360;

      bool inSegment;
      if (emotionStart > emotionEnd) {
        // Segment crosses 0 degrees
        inSegment = degrees >= emotionStart || degrees < emotionEnd;
      } else {
        inSegment = degrees >= emotionStart && degrees < emotionEnd;
      }

      if (inSegment) {
        // Apply intensity if it's a primary emotion
        Emotion selectedEmotion = emotion;
        if (emotion.type == EmotionType.primary) {
          final intensity = switch (ring) {
            0 => EmotionIntensity.mild,
            2 => EmotionIntensity.intense,
            _ => EmotionIntensity.moderate,
          };
          selectedEmotion = PlutchikEmotions.withIntensity(emotion, intensity);
        }

        HapticFeedback.selectionClick();
        setState(() {
          _selectedRing = ring;
        });
        widget.onEmotionSelected?.call(selectedEmotion);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = widget.size ??
            math.min(constraints.maxWidth, constraints.maxHeight);

        return AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _selectionAnimation]),
          builder: (context, child) {
            return GestureDetector(
              onPanUpdate: (details) =>
                  _handlePanUpdate(details, Size(size, size)),
              onTapUp: (details) => _handleTapUp(details, Size(size, size)),
              child: Transform.scale(
                scale: _pulseAnimation.value,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: CustomPaint(
                    painter: _EmotionWheelPainter(
                      rotation: _rotation,
                      selectedEmotion: widget.selectedEmotion,
                      hoveredEmotion: _hoveredEmotion,
                      showSecondaryEmotions: widget.showSecondaryEmotions,
                      selectionProgress: _selectionAnimation.value,
                      selectedRing: _selectedRing,
                    ),
                    child: _buildCenterContent(size),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCenterContent(double size) {
    final emotion = widget.selectedEmotion;

    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: emotion != null
            ? Container(
                key: ValueKey(emotion.id),
                width: size * 0.35,
                height: size * 0.35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background.withValues(alpha: 0.9),
                  boxShadow: [
                    BoxShadow(
                      color: emotion.color.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      emotion.name,
                      style: AppTypography.headlineSmall.copyWith(
                        color: emotion.color,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    if (emotion.intensity != EmotionIntensity.moderate)
                      Text(
                        emotion.intensity.name.toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 1.5,
                        ),
                      ),
                  ],
                ),
              )
            : Container(
                key: const ValueKey('empty'),
                width: size * 0.35,
                height: size * 0.35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background.withValues(alpha: 0.7),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      color: AppColors.textSecondary,
                      size: size * 0.08,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to select',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Custom painter for the emotion wheel
class _EmotionWheelPainter extends CustomPainter {
  _EmotionWheelPainter({
    required this.rotation,
    this.selectedEmotion,
    this.hoveredEmotion,
    this.showSecondaryEmotions = false,
    this.selectionProgress = 0.0,
    this.selectedRing = 1,
  });

  final double rotation;
  final Emotion? selectedEmotion;
  final Emotion? hoveredEmotion;
  final bool showSecondaryEmotions;
  final double selectionProgress;
  final int selectedRing;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Save canvas state for rotation
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    // Draw intensity rings (3 concentric rings)
    _drawIntensityRings(canvas, center, radius);

    // Draw emotion segments
    final emotions = showSecondaryEmotions
        ? PlutchikEmotions.allEmotions
        : PlutchikEmotions.primaryEmotions;
    final segmentAngle = 2 * math.pi / emotions.length;

    for (int i = 0; i < emotions.length; i++) {
      final emotion = emotions[i];
      final startAngle = (emotion.angle - 45 / (showSecondaryEmotions ? 2 : 1)) *
              math.pi /
              180 -
          math.pi / 2;

      _drawEmotionSegment(
        canvas,
        center,
        radius,
        startAngle,
        segmentAngle,
        emotion,
      );
    }

    // Restore canvas
    canvas.restore();

    // Draw selection glow (not rotated)
    if (selectedEmotion != null && selectionProgress > 0) {
      _drawSelectionGlow(canvas, center, radius);
    }
  }

  void _drawIntensityRings(Canvas canvas, Offset center, double radius) {
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.borderSubtle.withValues(alpha: 0.3);

    // Outer ring (mild)
    canvas.drawCircle(center, radius * 0.82, ringPaint);

    // Middle ring (moderate)
    canvas.drawCircle(center, radius * 0.57, ringPaint);

    // Inner ring (intense)
    canvas.drawCircle(center, radius * 0.32, ringPaint);
  }

  void _drawEmotionSegment(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    Emotion emotion,
  ) {
    final isSelected = selectedEmotion?.id == emotion.id ||
        (selectedEmotion?.id.startsWith(emotion.id) ?? false);
    final isHovered = hoveredEmotion?.id == emotion.id;

    // Define ring radii
    final outerRadius = radius * 0.95;
    final middleOuterRadius = radius * 0.70;
    final middleInnerRadius = radius * 0.45;
    final innerRadius = radius * 0.20;

    // Draw outer ring (mild intensity)
    _drawRingSegment(
      canvas,
      center,
      outerRadius,
      middleOuterRadius,
      startAngle,
      sweepAngle,
      emotion.color.withValues(alpha: 0.4),
      isSelected && selectedRing == 0,
      isHovered,
    );

    // Draw middle ring (moderate intensity)
    _drawRingSegment(
      canvas,
      center,
      middleOuterRadius,
      middleInnerRadius,
      startAngle,
      sweepAngle,
      emotion.color.withValues(alpha: 0.7),
      isSelected && selectedRing == 1,
      isHovered,
    );

    // Draw inner ring (intense)
    _drawRingSegment(
      canvas,
      center,
      middleInnerRadius,
      innerRadius,
      startAngle,
      sweepAngle,
      emotion.color,
      isSelected && selectedRing == 2,
      isHovered,
    );
  }

  void _drawRingSegment(
    Canvas canvas,
    Offset center,
    double outerRadius,
    double innerRadius,
    double startAngle,
    double sweepAngle,
    Color color,
    bool isSelected,
    bool isHovered,
  ) {
    final path = Path();

    // Outer arc
    path.addArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      startAngle,
      sweepAngle,
    );

    // Line to inner arc
    final innerEndX = center.dx + innerRadius * math.cos(startAngle + sweepAngle);
    final innerEndY = center.dy + innerRadius * math.sin(startAngle + sweepAngle);
    path.lineTo(innerEndX, innerEndY);

    // Inner arc (reverse direction)
    path.arcTo(
      Rect.fromCircle(center: center, radius: innerRadius),
      startAngle + sweepAngle,
      -sweepAngle,
      false,
    );

    // Close path
    path.close();

    // Fill paint
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isSelected
          ? color
          : isHovered
              ? color.withValues(alpha: color.a * 0.9)
              : color;

    canvas.drawPath(path, fillPaint);

    // Border paint
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 3 : 1
      ..color = isSelected
          ? Colors.white.withValues(alpha: 0.8)
          : AppColors.background.withValues(alpha: 0.5);

    canvas.drawPath(path, borderPaint);
  }

  void _drawSelectionGlow(Canvas canvas, Offset center, double radius) {
    if (selectedEmotion == null) return;

    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    // Calculate the angle of the selected emotion
    final angle = (selectedEmotion!.angle - 90) * math.pi / 180 + rotation;

    // Determine radius based on selected ring
    final glowRadius = switch (selectedRing) {
      0 => radius * 0.82,
      2 => radius * 0.32,
      _ => radius * 0.57,
    };

    final glowCenter = Offset(
      center.dx + glowRadius * math.cos(angle),
      center.dy + glowRadius * math.sin(angle),
    );

    glowPaint.color = selectedEmotion!.color.withValues(
      alpha: 0.4 * selectionProgress,
    );

    canvas.drawCircle(glowCenter, 40 * selectionProgress, glowPaint);
  }

  @override
  bool shouldRepaint(_EmotionWheelPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.selectedEmotion != selectedEmotion ||
        oldDelegate.hoveredEmotion != hoveredEmotion ||
        oldDelegate.showSecondaryEmotions != showSecondaryEmotions ||
        oldDelegate.selectionProgress != selectionProgress ||
        oldDelegate.selectedRing != selectedRing;
  }
}
