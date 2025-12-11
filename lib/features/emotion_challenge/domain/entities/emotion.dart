import 'package:flutter/material.dart';

/// Plutchik's Wheel of Emotions - Data Model
/// Based on Robert Plutchik's psycho-evolutionary theory of emotion (1980)
///
/// The wheel contains:
/// - 8 Primary emotions arranged in opposing pairs
/// - 8 Secondary emotions (dyads) formed by combining adjacent primaries
/// - 3 intensity levels for each primary emotion

/// Intensity level of an emotion
enum EmotionIntensity {
  /// Mild intensity (outer ring)
  mild,

  /// Moderate intensity (middle ring)
  moderate,

  /// Intense intensity (inner ring)
  intense,
}

/// Type of emotion
enum EmotionType {
  /// One of the 8 primary emotions
  primary,

  /// Combination of two adjacent primary emotions
  secondary,
}

/// Represents an emotion in Plutchik's wheel
class Emotion {
  const Emotion({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.description,
    required this.angle,
    this.intensity = EmotionIntensity.moderate,
    this.oppositeId,
    this.parentIds,
    this.intensityVariants,
  });

  /// Unique identifier
  final String id;

  /// Display name
  final String name;

  /// Type of emotion (primary or secondary)
  final EmotionType type;

  /// Color representing this emotion
  final Color color;

  /// Brief description of what this emotion feels like
  final String description;

  /// Position on the wheel in degrees (0-360, starting from top)
  final double angle;

  /// Intensity level (for primary emotions)
  final EmotionIntensity intensity;

  /// ID of the opposite emotion (for primary emotions)
  final String? oppositeId;

  /// IDs of parent emotions (for secondary emotions)
  final List<String>? parentIds;

  /// Map of intensity variants (for primary emotions)
  /// e.g., joy -> {mild: serenity, moderate: joy, intense: ecstasy}
  final Map<EmotionIntensity, String>? intensityVariants;

  /// Get the intensity variant name
  String getIntensityName(EmotionIntensity level) {
    return intensityVariants?[level] ?? name;
  }
}

/// Plutchik's primary emotions with their properties
class PlutchikEmotions {
  PlutchikEmotions._();

  // ============================================================================
  // Primary Emotions - 8 basic emotions arranged in opposing pairs
  // ============================================================================

  static const Emotion joy = Emotion(
    id: 'joy',
    name: 'Joy',
    type: EmotionType.primary,
    color: Color(0xFFFFEB3B), // Yellow
    description: 'A feeling of great pleasure and happiness',
    angle: 0,
    oppositeId: 'sadness',
    intensityVariants: {
      EmotionIntensity.mild: 'Serenity',
      EmotionIntensity.moderate: 'Joy',
      EmotionIntensity.intense: 'Ecstasy',
    },
  );

  static const Emotion trust = Emotion(
    id: 'trust',
    name: 'Trust',
    type: EmotionType.primary,
    color: Color(0xFF8BC34A), // Light Green
    description: 'Firm belief in reliability and safety',
    angle: 45,
    oppositeId: 'disgust',
    intensityVariants: {
      EmotionIntensity.mild: 'Acceptance',
      EmotionIntensity.moderate: 'Trust',
      EmotionIntensity.intense: 'Admiration',
    },
  );

  static const Emotion fear = Emotion(
    id: 'fear',
    name: 'Fear',
    type: EmotionType.primary,
    color: Color(0xFF4CAF50), // Green
    description: 'An unpleasant feeling triggered by perceived danger',
    angle: 90,
    oppositeId: 'anger',
    intensityVariants: {
      EmotionIntensity.mild: 'Apprehension',
      EmotionIntensity.moderate: 'Fear',
      EmotionIntensity.intense: 'Terror',
    },
  );

  static const Emotion surprise = Emotion(
    id: 'surprise',
    name: 'Surprise',
    type: EmotionType.primary,
    color: Color(0xFF00BCD4), // Cyan
    description: 'A feeling caused by something unexpected',
    angle: 135,
    oppositeId: 'anticipation',
    intensityVariants: {
      EmotionIntensity.mild: 'Distraction',
      EmotionIntensity.moderate: 'Surprise',
      EmotionIntensity.intense: 'Amazement',
    },
  );

  static const Emotion sadness = Emotion(
    id: 'sadness',
    name: 'Sadness',
    type: EmotionType.primary,
    color: Color(0xFF2196F3), // Blue
    description: 'A feeling of sorrow or unhappiness',
    angle: 180,
    oppositeId: 'joy',
    intensityVariants: {
      EmotionIntensity.mild: 'Pensiveness',
      EmotionIntensity.moderate: 'Sadness',
      EmotionIntensity.intense: 'Grief',
    },
  );

  static const Emotion disgust = Emotion(
    id: 'disgust',
    name: 'Disgust',
    type: EmotionType.primary,
    color: Color(0xFF9C27B0), // Purple
    description: 'A strong feeling of disapproval or revulsion',
    angle: 225,
    oppositeId: 'trust',
    intensityVariants: {
      EmotionIntensity.mild: 'Boredom',
      EmotionIntensity.moderate: 'Disgust',
      EmotionIntensity.intense: 'Loathing',
    },
  );

  static const Emotion anger = Emotion(
    id: 'anger',
    name: 'Anger',
    type: EmotionType.primary,
    color: Color(0xFFF44336), // Red
    description: 'A strong feeling of annoyance or hostility',
    angle: 270,
    oppositeId: 'fear',
    intensityVariants: {
      EmotionIntensity.mild: 'Annoyance',
      EmotionIntensity.moderate: 'Anger',
      EmotionIntensity.intense: 'Rage',
    },
  );

  static const Emotion anticipation = Emotion(
    id: 'anticipation',
    name: 'Anticipation',
    type: EmotionType.primary,
    color: Color(0xFFFF9800), // Orange
    description: 'Expectation or hope for something to happen',
    angle: 315,
    oppositeId: 'surprise',
    intensityVariants: {
      EmotionIntensity.mild: 'Interest',
      EmotionIntensity.moderate: 'Anticipation',
      EmotionIntensity.intense: 'Vigilance',
    },
  );

  // ============================================================================
  // Secondary Emotions - Combinations of adjacent primary emotions
  // ============================================================================

  static const Emotion love = Emotion(
    id: 'love',
    name: 'Love',
    type: EmotionType.secondary,
    color: Color(0xFFC6FF00), // Yellow-Green
    description: 'Joy + Trust: Deep affection and care',
    angle: 22.5,
    parentIds: ['joy', 'trust'],
  );

  static const Emotion submission = Emotion(
    id: 'submission',
    name: 'Submission',
    type: EmotionType.secondary,
    color: Color(0xFF69F0AE), // Light Teal
    description: 'Trust + Fear: Yielding to authority or influence',
    angle: 67.5,
    parentIds: ['trust', 'fear'],
  );

  static const Emotion awe = Emotion(
    id: 'awe',
    name: 'Awe',
    type: EmotionType.secondary,
    color: Color(0xFF00E5FF), // Light Cyan
    description: 'Fear + Surprise: Wonder mixed with reverence',
    angle: 112.5,
    parentIds: ['fear', 'surprise'],
  );

  static const Emotion disapproval = Emotion(
    id: 'disapproval',
    name: 'Disapproval',
    type: EmotionType.secondary,
    color: Color(0xFF448AFF), // Light Blue
    description: 'Surprise + Sadness: Unexpected disappointment',
    angle: 157.5,
    parentIds: ['surprise', 'sadness'],
  );

  static const Emotion remorse = Emotion(
    id: 'remorse',
    name: 'Remorse',
    type: EmotionType.secondary,
    color: Color(0xFF7C4DFF), // Deep Purple
    description: 'Sadness + Disgust: Deep regret for wrongdoing',
    angle: 202.5,
    parentIds: ['sadness', 'disgust'],
  );

  static const Emotion contempt = Emotion(
    id: 'contempt',
    name: 'Contempt',
    type: EmotionType.secondary,
    color: Color(0xFFE040FB), // Pink-Purple
    description: 'Disgust + Anger: Feeling of superiority and disdain',
    angle: 247.5,
    parentIds: ['disgust', 'anger'],
  );

  static const Emotion aggressiveness = Emotion(
    id: 'aggressiveness',
    name: 'Aggressiveness',
    type: EmotionType.secondary,
    color: Color(0xFFFF5722), // Deep Orange
    description: 'Anger + Anticipation: Ready to attack or confront',
    angle: 292.5,
    parentIds: ['anger', 'anticipation'],
  );

  static const Emotion optimism = Emotion(
    id: 'optimism',
    name: 'Optimism',
    type: EmotionType.secondary,
    color: Color(0xFFFFD54F), // Amber
    description: 'Anticipation + Joy: Hopefulness about the future',
    angle: 337.5,
    parentIds: ['anticipation', 'joy'],
  );

  // ============================================================================
  // Collections
  // ============================================================================

  /// All 8 primary emotions in wheel order (clockwise from top)
  static const List<Emotion> primaryEmotions = [
    joy,
    trust,
    fear,
    surprise,
    sadness,
    disgust,
    anger,
    anticipation,
  ];

  /// All 8 secondary emotions in wheel order
  static const List<Emotion> secondaryEmotions = [
    love,
    submission,
    awe,
    disapproval,
    remorse,
    contempt,
    aggressiveness,
    optimism,
  ];

  /// All emotions combined
  static List<Emotion> get allEmotions => [
        ...primaryEmotions,
        ...secondaryEmotions,
      ];

  /// Get emotion by ID
  static Emotion? getById(String id) {
    try {
      return allEmotions.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get the opposite emotion
  static Emotion? getOpposite(Emotion emotion) {
    if (emotion.oppositeId == null) return null;
    return getById(emotion.oppositeId!);
  }

  /// Get intensity variant of a primary emotion
  static Emotion withIntensity(Emotion emotion, EmotionIntensity intensity) {
    if (emotion.type != EmotionType.primary) return emotion;

    // Adjust color saturation based on intensity
    final HSLColor hsl = HSLColor.fromColor(emotion.color);
    final double saturationMultiplier = switch (intensity) {
      EmotionIntensity.mild => 0.5,
      EmotionIntensity.moderate => 0.75,
      EmotionIntensity.intense => 1.0,
    };
    final double lightnessAdjust = switch (intensity) {
      EmotionIntensity.mild => 0.2,
      EmotionIntensity.moderate => 0.0,
      EmotionIntensity.intense => -0.1,
    };

    final adjustedColor = hsl
        .withSaturation((hsl.saturation * saturationMultiplier).clamp(0.0, 1.0))
        .withLightness((hsl.lightness + lightnessAdjust).clamp(0.0, 1.0))
        .toColor();

    return Emotion(
      id: '${emotion.id}_${intensity.name}',
      name: emotion.getIntensityName(intensity),
      type: emotion.type,
      color: adjustedColor,
      description: emotion.description,
      angle: emotion.angle,
      intensity: intensity,
      oppositeId: emotion.oppositeId,
      intensityVariants: emotion.intensityVariants,
    );
  }
}
