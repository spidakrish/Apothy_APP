import 'package:hive/hive.dart';

import '../../domain/entities/user_stats.dart';

part 'user_stats_model.g.dart';

/// Hive type IDs for dashboard models
/// Using 20-29 range (chat uses 10-19)
abstract class DashboardHiveTypeIds {
  static const int userStatsModel = 20;
  static const int earnedAchievementModel = 21;
}

/// Hive model for storing user statistics locally
@HiveType(typeId: 20)
class UserStatsModel extends HiveObject {
  UserStatsModel({
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalConversations,
    required this.totalMessages,
    this.lastActiveDate,
  });

  @HiveField(0)
  final int totalXp;

  @HiveField(1)
  final int currentStreak;

  @HiveField(2)
  final int longestStreak;

  @HiveField(3)
  final int totalConversations;

  @HiveField(4)
  final int totalMessages;

  @HiveField(5)
  final DateTime? lastActiveDate;

  /// Create model from domain entity
  factory UserStatsModel.fromEntity(UserStats stats) {
    return UserStatsModel(
      totalXp: stats.totalXp,
      currentStreak: stats.currentStreak,
      longestStreak: stats.longestStreak,
      totalConversations: stats.totalConversations,
      totalMessages: stats.totalMessages,
      lastActiveDate: stats.lastActiveDate,
    );
  }

  /// Create empty/initial model
  factory UserStatsModel.empty() {
    return UserStatsModel(
      totalXp: 0,
      currentStreak: 0,
      longestStreak: 0,
      totalConversations: 0,
      totalMessages: 0,
      lastActiveDate: null,
    );
  }

  /// Convert to domain entity
  UserStats toEntity() {
    return UserStats(
      totalXp: totalXp,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalConversations: totalConversations,
      totalMessages: totalMessages,
      lastActiveDate: lastActiveDate,
    );
  }

  /// Create a copy with updated fields
  UserStatsModel copyWith({
    int? totalXp,
    int? currentStreak,
    int? longestStreak,
    int? totalConversations,
    int? totalMessages,
    DateTime? lastActiveDate,
  }) {
    return UserStatsModel(
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalConversations: totalConversations ?? this.totalConversations,
      totalMessages: totalMessages ?? this.totalMessages,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}
