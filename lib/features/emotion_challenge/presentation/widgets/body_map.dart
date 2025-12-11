import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/emotion.dart';

/// A point drawn on the body map with position and intensity
class BodyMapPoint {
  const BodyMapPoint({
    required this.position,
    required this.intensity,
    required this.radius,
  });

  /// Normalized position (0-1 for both x and y)
  final Offset position;

  /// Intensity of the sensation (0.0 - 1.0)
  final double intensity;

  /// Radius of the point
  final double radius;
}

/// Data representing the body sensation map
class BodyMapData {
  const BodyMapData({
    required this.emotion,
    required this.points,
    this.timestamp,
  });

  /// The emotion being mapped
  final Emotion emotion;

  /// All points drawn on the body
  final List<BodyMapPoint> points;

  /// When this map was created
  final DateTime? timestamp;

  /// Create empty body map for an emotion
  factory BodyMapData.empty(Emotion emotion) {
    return BodyMapData(
      emotion: emotion,
      points: [],
      timestamp: DateTime.now(),
    );
  }

  /// Create copy with new points
  BodyMapData copyWith({List<BodyMapPoint>? points}) {
    return BodyMapData(
      emotion: emotion,
      points: points ?? this.points,
      timestamp: timestamp,
    );
  }

  /// Get the primary body regions affected (for insights)
  List<String> get affectedRegions {
    final regions = <String>[];

    for (final point in points) {
      final region = _getRegionForPoint(point.position);
      if (!regions.contains(region)) {
        regions.add(region);
      }
    }

    return regions;
  }

  String _getRegionForPoint(Offset position) {
    // Simplified body region detection based on normalized coordinates
    final y = position.dy;
    final x = position.dx;

    if (y < 0.15) {
      return 'head';
    } else if (y < 0.25) {
      return 'neck';
    } else if (y < 0.45) {
      if (x < 0.3 || x > 0.7) {
        return 'shoulders';
      } else {
        return 'chest';
      }
    } else if (y < 0.55) {
      if (x < 0.25 || x > 0.75) {
        return 'arms';
      } else {
        return 'stomach';
      }
    } else if (y < 0.65) {
      if (x < 0.25 || x > 0.75) {
        return 'hands';
      } else {
        return 'lower abdomen';
      }
    } else if (y < 0.85) {
      return 'legs';
    } else {
      return 'feet';
    }
  }

  /// Generate emotion-specific insight based on the body map
  String generateInsight() {
    if (points.isEmpty) {
      return 'Tap on the body to mark where you feel ${emotion.name.toLowerCase()}.';
    }

    final regions = affectedRegions;
    final avgIntensity =
        points.map((p) => p.intensity).reduce((a, b) => a + b) / points.length;

    final intensityWord = avgIntensity > 0.7
        ? 'strongly'
        : avgIntensity > 0.4
            ? 'moderately'
            : 'subtly';

    final emotionId = emotion.id.split('_').first;
    final primaryRegion = regions.isNotEmpty ? regions.first : '';

    // Generate emotion-specific insight
    final emotionInsight = _getEmotionSpecificInsight(emotionId, primaryRegion);

    if (regions.length == 1) {
      return 'You feel ${emotion.name.toLowerCase()} $intensityWord in your ${regions.first}. $emotionInsight';
    } else if (regions.length <= 3) {
      final regionList = '${regions.take(regions.length - 1).join(', ')} and ${regions.last}';
      return 'You feel ${emotion.name.toLowerCase()} $intensityWord in your $regionList. $emotionInsight';
    } else {
      return 'You feel ${emotion.name.toLowerCase()} throughout your body, particularly in your ${regions.take(3).join(", ")}. $emotionInsight';
    }
  }

  /// Get emotion-specific insight about body sensations
  String _getEmotionSpecificInsight(String emotionId, String primaryRegion) {
    return switch (emotionId) {
      'fear' => _getFearInsight(primaryRegion),
      'anger' => _getAngerInsight(primaryRegion),
      'sadness' => _getSadnessInsight(primaryRegion),
      'joy' => _getJoyInsight(primaryRegion),
      'trust' => _getTrustInsight(primaryRegion),
      'surprise' => _getSurpriseInsight(primaryRegion),
      'disgust' => _getDisgustInsight(primaryRegion),
      'anticipation' => _getAnticipationInsight(primaryRegion),
      'love' => _getLoveInsight(primaryRegion),
      'submission' => _getSubmissionInsight(primaryRegion),
      'awe' => _getAweInsight(primaryRegion),
      'disapproval' => _getDisapprovalInsight(primaryRegion),
      'remorse' => _getRemorseInsight(primaryRegion),
      'contempt' => _getContemptInsight(primaryRegion),
      'aggressiveness' => _getAggressivenessInsight(primaryRegion),
      'optimism' => _getOptimismInsight(primaryRegion),
      _ => 'This pattern reveals how your body holds this emotion.',
    };
  }

  String _getFearInsight(String region) => switch (region) {
    'chest' => 'Fear in the chest often shows as rapid heartbeat or tightness—your body preparing for danger.',
    'stomach' => 'The "butterflies" or churning in your stomach is your gut responding to perceived threat.',
    'shoulders' => 'Raised shoulders are a protective response, bracing against what feels unsafe.',
    'neck' => 'Neck tension from fear reflects the body\'s readiness to look for danger.',
    'hands' => 'Trembling or cold hands occur when blood rushes to core muscles for protection.',
    _ => 'Fear activates your survival system, preparing your body to respond to threat.',
  };

  String _getAngerInsight(String region) => switch (region) {
    'chest' => 'Anger in the chest reflects the heat and energy of a boundary being defended.',
    'jaw' || 'head' => 'Jaw clenching is a common anger response—literally biting back what you want to say.',
    'shoulders' => 'Tense shoulders from anger prepare you to push back or fight.',
    'stomach' => 'Anger churning in your gut signals that something feels fundamentally wrong.',
    'hands' => 'Clenched fists show your body\'s readiness to take action or defend yourself.',
    _ => 'Anger generates heat and tension as your body mobilizes to protect what matters.',
  };

  String _getSadnessInsight(String region) => switch (region) {
    'chest' => 'The heavy feeling in your chest is your heart literally feeling the weight of loss.',
    'stomach' => 'Sadness in your stomach reflects how grief affects your core, your center.',
    'head' => 'Sadness can manifest as pressure or heaviness in the head, clouding thinking.',
    'shoulders' => 'Slumped or heavy shoulders show how sadness physically weighs us down.',
    'neck' => 'A tight throat is your body holding back tears or words of grief.',
    _ => 'Sadness creates heaviness and slowness, your body processing loss and change.',
  };

  String _getJoyInsight(String region) => switch (region) {
    'chest' => 'Joy expanding in your chest is your heart literally opening and lifting.',
    'stomach' => 'That light, warm feeling in your stomach is happiness radiating from your core.',
    'head' => 'Joy in your head creates clarity and brightness, making everything feel possible.',
    'shoulders' => 'Relaxed, open shoulders show joy releasing the weight you normally carry.',
    'hands' => 'Joy often shows in hands that want to reach out, create, or connect.',
    _ => 'Joy creates lightness and expansion, your body celebrating what feels good.',
  };

  String _getTrustInsight(String region) => switch (region) {
    'chest' => 'An open chest shows trust allowing your heart to be visible and undefended.',
    'stomach' => 'A calm stomach signals that your gut feels safe enough to relax.',
    'shoulders' => 'Released shoulders indicate trust allowing you to lower your defenses.',
    'neck' => 'A relaxed neck shows you don\'t need to constantly scan for danger.',
    _ => 'Trust creates softness and openness, your body feeling safe enough to relax.',
  };

  String _getSurpriseInsight(String region) => switch (region) {
    'head' => 'Surprise often hits the head first—your mind scrambling to process the unexpected.',
    'chest' => 'A sudden jolt in your chest reflects your nervous system\'s quick response.',
    'stomach' => 'That flip in your stomach is your body reacting before your mind catches up.',
    'shoulders' => 'Raised shoulders show your body startling and preparing to respond.',
    _ => 'Surprise creates quick, sharp sensations as your body responds to the unexpected.',
  };

  String _getDisgustInsight(String region) => switch (region) {
    'stomach' => 'Disgust in your stomach is a primal rejection response, wanting to expel what feels wrong.',
    'chest' => 'Disgust tightening your chest shows your body physically recoiling.',
    'head' || 'face' => 'Facial disgust (nose wrinkle, lip curl) is hardwired to protect you from toxins.',
    'neck' => 'A constricted throat shows your body trying to block what feels harmful.',
    _ => 'Disgust creates contraction and rejection, your body protecting its boundaries.',
  };

  String _getAnticipationInsight(String region) => switch (region) {
    'stomach' => 'Anticipation in your stomach is excitement mixed with uncertainty about what\'s coming.',
    'chest' => 'A racing heart from anticipation shows your body getting ready for what\'s next.',
    'shoulders' => 'Tense shoulders reflect your body\'s readiness and alertness.',
    'hands' => 'Restless hands show anticipation\'s energy looking for somewhere to go.',
    _ => 'Anticipation creates alertness and readiness, your body on standby.',
  };

  String _getLoveInsight(String region) => switch (region) {
    'chest' => 'Love in the chest is your heart literally expanding to hold another person.',
    'stomach' => 'That warm glow in your stomach is love\'s energy radiating from your core.',
    'head' => 'Love creates a soft focus, filtering the world through connection and care.',
    'hands' => 'Hands that want to reach out or hold show love\'s natural desire to connect.',
    _ => 'Love creates warmth and expansion, your body opening to deep connection.',
  };

  String _getSubmissionInsight(String region) => switch (region) {
    'shoulders' => 'Collapsed shoulders show submission making your body smaller and less visible.',
    'stomach' => 'A tight stomach reflects the fear that keeps you from speaking up.',
    'chest' => 'A closed chest protects your heart when assertion feels too risky.',
    'neck' => 'A lowered head shows submission\'s posture of making yourself small.',
    _ => 'Submission creates contraction and smallness, your body protecting through yielding.',
  };

  String _getAweInsight(String region) => switch (region) {
    'chest' => 'Awe expanding your chest is your heart trying to hold something vast.',
    'head' => 'That tingling or opening in your head is awe shifting your perspective.',
    'stomach' => 'Awe in your stomach creates a profound sense of something beyond yourself.',
    'shoulders' => 'Dropped shoulders show awe releasing your normal concerns.',
    _ => 'Awe creates expansion and tingling, your body responding to the extraordinary.',
  };

  String _getDisapprovalInsight(String region) => switch (region) {
    'chest' => 'Disapproval tightening your chest shows judgment creating distance.',
    'stomach' => 'That churning in your stomach reflects discomfort with what you\'re witnessing.',
    'face' || 'head' => 'Facial tension (furrowed brow, tight jaw) shows disapproval\'s judgment.',
    'shoulders' => 'Tense shoulders show disapproval preparing to resist or push back.',
    _ => 'Disapproval creates tension and distance, your body marking what feels wrong.',
  };

  String _getRemorseInsight(String region) => switch (region) {
    'chest' => 'Remorse weighing on your chest is your heart feeling the impact of your actions.',
    'stomach' => 'That sinking feeling in your stomach is regret settling into your core.',
    'shoulders' => 'Heavy shoulders show remorse literally weighing you down with responsibility.',
    'head' => 'Remorse can create pressure in your head as you replay what happened.',
    _ => 'Remorse creates heaviness and sinking, your body feeling the weight of regret.',
  };

  String _getContemptInsight(String region) => switch (region) {
    'face' || 'head' => 'Facial contempt (sneering, eye-rolling) is your body showing superiority.',
    'chest' => 'A tight, closed chest shows contempt creating emotional distance.',
    'stomach' => 'Contempt in your stomach shows how disdain affects you physically.',
    'shoulders' => 'Raised shoulders can signal contempt\'s defensive superiority.',
    _ => 'Contempt creates hardness and distance, your body expressing superiority.',
  };

  String _getAggressivenessInsight(String region) => switch (region) {
    'chest' => 'Aggression surging in your chest mobilizes energy for confrontation.',
    'jaw' || 'head' => 'A clenched jaw shows aggressive energy ready to bite or attack.',
    'shoulders' => 'Tense shoulders prepare for aggressive action—to push, fight, or dominate.',
    'stomach' => 'Aggression in your gut is primal, instinctive readiness for conflict.',
    'hands' => 'Clenched fists show aggression ready to strike or establish dominance.',
    _ => 'Aggressiveness creates intensity and mobilization, your body ready for confrontation.',
  };

  String _getOptimismInsight(String region) => switch (region) {
    'chest' => 'Optimism lifting your chest is hope making your heart feel lighter.',
    'stomach' => 'That bright feeling in your stomach is optimism\'s positive anticipation.',
    'head' => 'Optimism creates mental clarity and forward-looking focus.',
    'shoulders' => 'Lifted shoulders show optimism releasing heaviness and opening possibilities.',
    _ => 'Optimism creates lightness and forward energy, your body feeling hopeful.',
  };
}

/// Interactive body map for painting sensations
class BodyMap extends StatefulWidget {
  const BodyMap({
    super.key,
    required this.emotion,
    this.onMapUpdated,
    this.initialData,
    this.brushIntensity = 0.7,
  });

  /// The emotion being mapped
  final Emotion emotion;

  /// Callback when the map is updated
  final ValueChanged<BodyMapData>? onMapUpdated;

  /// Initial map data (for editing)
  final BodyMapData? initialData;

  /// Current brush intensity (0.0 - 1.0)
  final double brushIntensity;

  @override
  State<BodyMap> createState() => BodyMapState();
}

class BodyMapState extends State<BodyMap> with SingleTickerProviderStateMixin {
  late List<BodyMapPoint> _points;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Brush settings
  static const double _brushRadius = 25.0;

  @override
  void initState() {
    super.initState();
    _points = widget.initialData?.points.toList() ?? [];

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _addPoint(Offset localPosition, Size size) {
    // Normalize position to 0-1 range
    final normalizedPosition = Offset(
      localPosition.dx / size.width,
      localPosition.dy / size.height,
    );

    // Check if within body silhouette bounds (approximate)
    if (!_isWithinBody(normalizedPosition)) return;

    HapticFeedback.selectionClick();

    setState(() {
      _points.add(BodyMapPoint(
        position: normalizedPosition,
        intensity: widget.brushIntensity,
        radius: _brushRadius,
      ));
    });

    _notifyUpdate();
  }

  bool _isWithinBody(Offset normalizedPosition) {
    final x = normalizedPosition.dx;
    final y = normalizedPosition.dy;

    // Simple bounding box check (body is roughly centered)
    // Head region
    if (y < 0.18) {
      return x > 0.35 && x < 0.65;
    }
    // Neck
    if (y < 0.22) {
      return x > 0.42 && x < 0.58;
    }
    // Shoulders and upper body
    if (y < 0.35) {
      return x > 0.15 && x < 0.85;
    }
    // Arms and torso
    if (y < 0.55) {
      return x > 0.08 && x < 0.92;
    }
    // Hands and hips
    if (y < 0.62) {
      return x > 0.05 && x < 0.95;
    }
    // Upper legs
    if (y < 0.80) {
      return (x > 0.25 && x < 0.45) || (x > 0.55 && x < 0.75);
    }
    // Lower legs and feet
    if (y < 0.98) {
      return (x > 0.28 && x < 0.42) || (x > 0.58 && x < 0.72);
    }

    return false;
  }

  void _notifyUpdate() {
    widget.onMapUpdated?.call(BodyMapData(
      emotion: widget.emotion,
      points: _points,
      timestamp: DateTime.now(),
    ));
  }

  void clearMap() {
    setState(() {
      _points.clear();
    });
    _notifyUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        return GestureDetector(
          onTapDown: (details) => _addPoint(details.localPosition, size),
          onPanUpdate: (details) => _addPoint(details.localPosition, size),
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: _BodyMapPainter(
                  points: _points,
                  emotionColor: widget.emotion.color,
                  pulseScale: _pulseAnimation.value,
                ),
                size: size,
                child: child,
              );
            },
            child: _buildBodySilhouette(size),
          ),
        );
      },
    );
  }

  Widget _buildBodySilhouette(Size size) {
    // Use a simple vector-style body outline
    return CustomPaint(
      painter: _BodySilhouettePainter(),
      size: size,
    );
  }
}

/// Painter for the body silhouette outline
class _BodySilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = AppColors.surface.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path = _createBodyPath(size);

    // Draw fill first
    canvas.drawPath(path, fillPaint);
    // Draw outline
    canvas.drawPath(path, paint);
  }

  Path _createBodyPath(Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();

    // Head (circle)
    final headCenterX = w * 0.5;
    final headCenterY = h * 0.08;
    final headRadius = w * 0.12;

    path.addOval(Rect.fromCircle(
      center: Offset(headCenterX, headCenterY),
      radius: headRadius,
    ));

    // Neck
    path.moveTo(w * 0.45, h * 0.15);
    path.lineTo(w * 0.45, h * 0.20);

    path.moveTo(w * 0.55, h * 0.15);
    path.lineTo(w * 0.55, h * 0.20);

    // Body outline
    final bodyPath = Path();

    // Left shoulder
    bodyPath.moveTo(w * 0.45, h * 0.20);
    bodyPath.quadraticBezierTo(w * 0.35, h * 0.20, w * 0.18, h * 0.25);

    // Left arm
    bodyPath.lineTo(w * 0.12, h * 0.45);
    bodyPath.quadraticBezierTo(w * 0.08, h * 0.52, w * 0.10, h * 0.58);

    // Left hand
    bodyPath.quadraticBezierTo(w * 0.06, h * 0.62, w * 0.12, h * 0.60);
    bodyPath.lineTo(w * 0.18, h * 0.50);

    // Left side of torso
    bodyPath.lineTo(w * 0.25, h * 0.35);
    bodyPath.lineTo(w * 0.28, h * 0.60);

    // Left leg
    bodyPath.lineTo(w * 0.30, h * 0.85);
    bodyPath.quadraticBezierTo(w * 0.30, h * 0.95, w * 0.32, h * 0.97);

    // Left foot
    bodyPath.lineTo(w * 0.38, h * 0.97);
    bodyPath.quadraticBezierTo(w * 0.40, h * 0.95, w * 0.40, h * 0.85);

    // Inner left leg
    bodyPath.lineTo(w * 0.42, h * 0.60);

    // Crotch
    bodyPath.quadraticBezierTo(w * 0.50, h * 0.62, w * 0.58, h * 0.60);

    // Inner right leg
    bodyPath.lineTo(w * 0.60, h * 0.85);
    bodyPath.quadraticBezierTo(w * 0.60, h * 0.95, w * 0.62, h * 0.97);

    // Right foot
    bodyPath.lineTo(w * 0.68, h * 0.97);
    bodyPath.quadraticBezierTo(w * 0.70, h * 0.95, w * 0.70, h * 0.85);

    // Right leg
    bodyPath.lineTo(w * 0.72, h * 0.60);

    // Right side of torso
    bodyPath.lineTo(w * 0.75, h * 0.35);
    bodyPath.lineTo(w * 0.82, h * 0.50);

    // Right hand
    bodyPath.lineTo(w * 0.88, h * 0.60);
    bodyPath.quadraticBezierTo(w * 0.94, h * 0.62, w * 0.90, h * 0.58);

    // Right arm
    bodyPath.quadraticBezierTo(w * 0.92, h * 0.52, w * 0.88, h * 0.45);
    bodyPath.lineTo(w * 0.82, h * 0.25);

    // Right shoulder
    bodyPath.quadraticBezierTo(w * 0.65, h * 0.20, w * 0.55, h * 0.20);

    bodyPath.close();

    path.addPath(bodyPath, Offset.zero);

    return path;
  }

  @override
  bool shouldRepaint(_BodySilhouettePainter oldDelegate) => false;
}

/// Painter for the sensation points on the body
class _BodyMapPainter extends CustomPainter {
  _BodyMapPainter({
    required this.points,
    required this.emotionColor,
    required this.pulseScale,
  });

  final List<BodyMapPoint> points;
  final Color emotionColor;
  final double pulseScale;

  @override
  void paint(Canvas canvas, Size size) {
    for (final point in points) {
      _drawSensationPoint(canvas, size, point);
    }
  }

  void _drawSensationPoint(Canvas canvas, Size size, BodyMapPoint point) {
    final center = Offset(
      point.position.dx * size.width,
      point.position.dy * size.height,
    );

    final radius = point.radius * pulseScale;

    // Determine color based on intensity (warm = high, cool = low)
    final color = _getIntensityColor(point.intensity);

    // Draw outer glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.2 * point.intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(center, radius * 1.5, glowPaint);

    // Draw gradient circle
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.8 * point.intensity),
          color.withValues(alpha: 0.3 * point.intensity),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, gradientPaint);
  }

  Color _getIntensityColor(double intensity) {
    // Blend between emotion color and a warm/cool variation based on intensity
    if (intensity > 0.6) {
      // High intensity - use emotion color with red/orange tint
      return Color.lerp(emotionColor, Colors.orange, (intensity - 0.6) * 0.5)!;
    } else if (intensity < 0.4) {
      // Low intensity - cooler version of emotion color
      return Color.lerp(emotionColor, Colors.blue, (0.4 - intensity) * 0.5)!;
    }
    return emotionColor;
  }

  @override
  bool shouldRepaint(_BodyMapPainter oldDelegate) =>
      oldDelegate.points.length != points.length ||
      oldDelegate.emotionColor != emotionColor ||
      oldDelegate.pulseScale != pulseScale;
}
