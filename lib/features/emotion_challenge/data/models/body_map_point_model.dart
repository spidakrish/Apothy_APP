import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../presentation/widgets/body_map.dart';
import 'reflection_response_model.dart';

part 'body_map_point_model.g.dart';

/// Data model for a body map point with Hive persistence
///
/// Decomposes Flutter's Offset into separate x/y coordinates
/// since Offset is not Hive-serializable
@HiveType(typeId: EmotionChallengeHiveTypeIds.bodyMapPoint)
class BodyMapPointModel {
  BodyMapPointModel({
    required this.positionX,
    required this.positionY,
    required this.intensity,
    required this.radius,
  });

  /// X coordinate (normalized 0-1)
  @HiveField(0)
  final double positionX;

  /// Y coordinate (normalized 0-1)
  @HiveField(1)
  final double positionY;

  /// Intensity of the sensation (0.0 - 1.0)
  @HiveField(2)
  final double intensity;

  /// Radius of the point
  @HiveField(3)
  final double radius;

  /// Create from BodyMapPoint entity
  factory BodyMapPointModel.fromEntity(BodyMapPoint point) {
    return BodyMapPointModel(
      positionX: point.position.dx,
      positionY: point.position.dy,
      intensity: point.intensity,
      radius: point.radius,
    );
  }

  /// Convert to BodyMapPoint entity
  BodyMapPoint toEntity() {
    return BodyMapPoint(
      position: Offset(positionX, positionY),
      intensity: intensity,
      radius: radius,
    );
  }

  /// Create a copy with updated fields
  BodyMapPointModel copyWith({
    double? positionX,
    double? positionY,
    double? intensity,
    double? radius,
  }) {
    return BodyMapPointModel(
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      intensity: intensity ?? this.intensity,
      radius: radius ?? this.radius,
    );
  }

  @override
  String toString() {
    return 'BodyMapPointModel(x: $positionX, y: $positionY, intensity: $intensity, radius: $radius)';
  }
}
