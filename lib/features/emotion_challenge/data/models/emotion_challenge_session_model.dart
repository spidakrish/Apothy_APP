import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/emotion.dart';
import '../../domain/entities/emotion_challenge_session.dart';
import 'body_map_point_model.dart';
import 'reflection_response_model.dart';

part 'emotion_challenge_session_model.g.dart';

/// Data model for an emotion challenge session with Hive persistence
///
/// Stores all data from a complete emotion challenge journey:
/// - Emotion selection (Phase 1)
/// - Body mapping (Phase 2)
/// - Somatic scan (Phase 3) - completion tracked
/// - Cognitive reframing (Phase 4) - score tracked
/// - Reflections (Phase 5) - responses tracked
@HiveType(typeId: EmotionChallengeHiveTypeIds.emotionChallengeSession)
class EmotionChallengeSessionModel extends HiveObject {
  EmotionChallengeSessionModel({
    required this.id,
    required this.emotionId,
    required this.emotionName,
    required this.emotionColorValue,
    required this.emotionIntensity,
    required this.bodyMapPoints,
    required this.cbtScore,
    required this.reflections,
    required this.startedAt,
    required this.completedAt,
    required this.xpEarned,
  });

  /// Unique session ID (UUID)
  @HiveField(0)
  final String id;

  /// Emotion ID (e.g., "joy", "sadness", "anger")
  @HiveField(1)
  final String emotionId;

  /// Emotion name (e.g., "Joy", "Sadness", "Anger")
  @HiveField(2)
  final String emotionName;

  /// Emotion color as integer value (Color.value)
  /// Can be reconstructed with Color(emotionColorValue)
  @HiveField(3)
  final int emotionColorValue;

  /// Emotion intensity level as string ("mild", "moderate", "intense")
  @HiveField(4)
  final String emotionIntensity;

  /// Body map points from Phase 2
  @HiveField(5)
  final List<BodyMapPointModel> bodyMapPoints;

  /// CBT score from Phase 4 (cognitive reframing)
  @HiveField(6)
  final int cbtScore;

  /// Reflection responses from Phase 5
  @HiveField(7)
  final List<ReflectionResponseModel> reflections;

  /// When the session was started
  @HiveField(8)
  final DateTime startedAt;

  /// When the session was completed
  @HiveField(9)
  final DateTime completedAt;

  /// XP earned from this session (always 50 for complete sessions)
  @HiveField(10)
  final int xpEarned;

  /// Number of answered reflections
  int get answeredReflectionsCount {
    return reflections.where((r) => r.isAnswered).length;
  }

  /// Number of body regions marked
  int get bodyRegionsCount {
    return bodyMapPoints.length;
  }

  /// Check if session is complete (has all required data)
  bool get isComplete {
    return bodyMapPoints.isNotEmpty &&
        cbtScore > 0 &&
        reflections.isNotEmpty;
  }

  /// Create from EmotionChallengeSession entity
  factory EmotionChallengeSessionModel.fromEntity(
    EmotionChallengeSession session,
  ) {
    return EmotionChallengeSessionModel(
      id: session.id,
      emotionId: session.emotion.id,
      emotionName: session.emotion.name,
      emotionColorValue: session.emotion.color.value,
      emotionIntensity: session.emotion.intensity.name,
      bodyMapPoints: session.bodyMapPoints
          .map((point) => BodyMapPointModel.fromEntity(point))
          .toList(),
      cbtScore: session.cbtScore,
      reflections: session.reflections
          .map((r) => ReflectionResponseModel.fromEntity(r))
          .toList(),
      startedAt: session.startedAt,
      completedAt: session.completedAt,
      xpEarned: session.xpEarned,
    );
  }

  /// Convert to EmotionChallengeSession entity
  EmotionChallengeSession toEntity() {
    // Reconstruct the Emotion object
    // First try to find it by ID in PlutchikEmotions
    Emotion? emotion = PlutchikEmotions.getById(emotionId);

    // If not found, create a basic emotion object
    if (emotion == null) {
      emotion = Emotion(
        id: emotionId,
        name: emotionName,
        type: EmotionType.primary,
        color: Color(emotionColorValue),
        description: '',
        angle: 0,
        intensity: EmotionIntensity.values.firstWhere(
          (e) => e.name == emotionIntensity,
          orElse: () => EmotionIntensity.moderate,
        ),
      );
    } else {
      // Apply the intensity from the saved session
      final intensity = EmotionIntensity.values.firstWhere(
        (e) => e.name == emotionIntensity,
        orElse: () => EmotionIntensity.moderate,
      );
      emotion = PlutchikEmotions.withIntensity(emotion, intensity);
    }

    return EmotionChallengeSession(
      id: id,
      emotion: emotion,
      bodyMapPoints: bodyMapPoints.map((p) => p.toEntity()).toList(),
      cbtScore: cbtScore,
      reflections: reflections.map((r) => r.toEntity()).toList(),
      startedAt: startedAt,
      completedAt: completedAt,
      xpEarned: xpEarned,
    );
  }

  /// Create a copy with updated fields
  EmotionChallengeSessionModel copyWith({
    String? id,
    String? emotionId,
    String? emotionName,
    int? emotionColorValue,
    String? emotionIntensity,
    List<BodyMapPointModel>? bodyMapPoints,
    int? cbtScore,
    List<ReflectionResponseModel>? reflections,
    DateTime? startedAt,
    DateTime? completedAt,
    int? xpEarned,
  }) {
    return EmotionChallengeSessionModel(
      id: id ?? this.id,
      emotionId: emotionId ?? this.emotionId,
      emotionName: emotionName ?? this.emotionName,
      emotionColorValue: emotionColorValue ?? this.emotionColorValue,
      emotionIntensity: emotionIntensity ?? this.emotionIntensity,
      bodyMapPoints: bodyMapPoints ?? this.bodyMapPoints,
      cbtScore: cbtScore ?? this.cbtScore,
      reflections: reflections ?? this.reflections,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }

  @override
  String toString() {
    return 'EmotionChallengeSessionModel(id: $id, emotion: $emotionName, '
        'intensity: $emotionIntensity, bodyPoints: ${bodyMapPoints.length}, '
        'cbtScore: $cbtScore, reflections: $answeredReflectionsCount/${reflections.length}, '
        'xp: $xpEarned)';
  }
}
