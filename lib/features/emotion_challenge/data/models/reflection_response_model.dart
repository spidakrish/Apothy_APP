import 'package:hive/hive.dart';

import '../../domain/entities/emotion_challenge_session.dart';

part 'reflection_response_model.g.dart';

/// Hive type IDs for emotion challenge models
/// Using 30-39 range to avoid conflicts with other features
abstract class EmotionChallengeHiveTypeIds {
  static const int emotionChallengeSession = 30;
  static const int bodyMapPoint = 31;
  static const int reflectionResponse = 32;
}

/// Data model for a reflection question response with Hive persistence
@HiveType(typeId: EmotionChallengeHiveTypeIds.reflectionResponse)
class ReflectionResponseModel {
  ReflectionResponseModel({
    required this.question,
    required this.response,
    required this.isAnswered,
  });

  @HiveField(0)
  final String question;

  @HiveField(1)
  final String response;

  @HiveField(2)
  final bool isAnswered;

  /// Create from ReflectionResponse entity
  factory ReflectionResponseModel.fromEntity(ReflectionResponse response) {
    return ReflectionResponseModel(
      question: response.question,
      response: response.response,
      isAnswered: response.isAnswered,
    );
  }

  /// Convert to ReflectionResponse entity
  ReflectionResponse toEntity() {
    return ReflectionResponse(
      question: question,
      response: response,
      isAnswered: isAnswered,
    );
  }

  /// Create a copy with updated fields
  ReflectionResponseModel copyWith({
    String? question,
    String? response,
    bool? isAnswered,
  }) {
    return ReflectionResponseModel(
      question: question ?? this.question,
      response: response ?? this.response,
      isAnswered: isAnswered ?? this.isAnswered,
    );
  }

  @override
  String toString() {
    return 'ReflectionResponseModel(question: $question, response: $response, isAnswered: $isAnswered)';
  }
}
