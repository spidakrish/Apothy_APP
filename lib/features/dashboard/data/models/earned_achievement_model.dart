import 'package:hive/hive.dart';

part 'earned_achievement_model.g.dart';

/// Hive model for storing earned achievements locally
///
/// This only stores the achievement ID and when it was earned.
/// The achievement details (title, description, etc.) come from
/// the predefined Achievements class.
@HiveType(typeId: 21)
class EarnedAchievementModel extends HiveObject {
  EarnedAchievementModel({
    required this.achievementId,
    required this.earnedAt,
  });

  /// The ID of the achievement that was earned
  @HiveField(0)
  final String achievementId;

  /// When the achievement was earned
  @HiveField(1)
  final DateTime earnedAt;
}
