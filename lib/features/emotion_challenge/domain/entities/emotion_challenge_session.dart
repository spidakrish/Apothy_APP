import 'package:equatable/equatable.dart';

import '../../presentation/widgets/body_map.dart';
import 'emotion.dart';

/// A reflection question with user response
class ReflectionResponse extends Equatable {
  const ReflectionResponse({
    required this.question,
    required this.response,
    required this.isAnswered,
  });

  final String question;
  final String response;
  final bool isAnswered;

  @override
  List<Object?> get props => [question, response, isAnswered];

  ReflectionResponse copyWith({
    String? question,
    String? response,
    bool? isAnswered,
  }) {
    return ReflectionResponse(
      question: question ?? this.question,
      response: response ?? this.response,
      isAnswered: isAnswered ?? this.isAnswered,
    );
  }
}

/// Represents a complete emotion challenge session
///
/// Contains all data from the 5-phase journey:
/// - Phase 1: Emotion selection
/// - Phase 2: Body mapping
/// - Phase 3: Somatic scan (completion tracked)
/// - Phase 4: Cognitive reframing (CBT score)
/// - Phase 5: Reflections
class EmotionChallengeSession extends Equatable {
  const EmotionChallengeSession({
    required this.id,
    required this.emotion,
    required this.bodyMapPoints,
    required this.cbtScore,
    required this.reflections,
    required this.startedAt,
    required this.completedAt,
    required this.xpEarned,
  });

  /// Unique session ID
  final String id;

  /// The emotion explored in this session
  final Emotion emotion;

  /// Body map points from Phase 2
  final List<BodyMapPoint> bodyMapPoints;

  /// CBT score from Phase 4 (cognitive reframing)
  final int cbtScore;

  /// Reflection responses from Phase 5
  final List<ReflectionResponse> reflections;

  /// When the session was started
  final DateTime startedAt;

  /// When the session was completed
  final DateTime completedAt;

  /// XP earned from this session
  final int xpEarned;

  /// Number of answered reflections
  int get answeredReflectionsCount {
    return reflections.where((r) => r.isAnswered).length;
  }

  /// Get affected body regions
  List<String> get affectedRegions {
    final bodyMapData = BodyMapData(
      emotion: emotion,
      points: bodyMapPoints,
      timestamp: startedAt,
    );
    return bodyMapData.affectedRegions;
  }

  /// Check if session is complete
  bool get isComplete {
    return bodyMapPoints.isNotEmpty &&
        cbtScore > 0 &&
        reflections.isNotEmpty;
  }

  /// Duration of the session
  Duration get duration {
    return completedAt.difference(startedAt);
  }

  @override
  List<Object?> get props => [
        id,
        emotion,
        bodyMapPoints,
        cbtScore,
        reflections,
        startedAt,
        completedAt,
        xpEarned,
      ];

  EmotionChallengeSession copyWith({
    String? id,
    Emotion? emotion,
    List<BodyMapPoint>? bodyMapPoints,
    int? cbtScore,
    List<ReflectionResponse>? reflections,
    DateTime? startedAt,
    DateTime? completedAt,
    int? xpEarned,
  }) {
    return EmotionChallengeSession(
      id: id ?? this.id,
      emotion: emotion ?? this.emotion,
      bodyMapPoints: bodyMapPoints ?? this.bodyMapPoints,
      cbtScore: cbtScore ?? this.cbtScore,
      reflections: reflections ?? this.reflections,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }
}
