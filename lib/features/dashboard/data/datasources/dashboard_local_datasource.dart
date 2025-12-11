import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/earned_achievement_model.dart';
import '../models/user_stats_model.dart';

/// Storage keys for dashboard Hive boxes
abstract class DashboardStorageKeys {
  static const String userStatsBox = 'user_stats';
  static const String earnedAchievementsBox = 'earned_achievements';
  static const String userStatsKey = 'stats';
}

/// Abstract interface for dashboard local storage operations
abstract class DashboardLocalDatasource {
  /// Initialize the datasource (open Hive boxes)
  Future<void> initialize();

  /// Get the current user stats
  Future<UserStatsModel> getUserStats();

  /// Save user stats
  Future<void> saveUserStats(UserStatsModel stats);

  /// Get all earned achievement IDs
  Future<List<EarnedAchievementModel>> getEarnedAchievements();

  /// Check if an achievement has been earned
  Future<bool> isAchievementEarned(String achievementId);

  /// Save an earned achievement
  Future<void> saveEarnedAchievement(EarnedAchievementModel achievement);

  /// Clear all dashboard data
  Future<void> clearAll();
}

/// Implementation of DashboardLocalDatasource using Hive
class DashboardLocalDatasourceImpl implements DashboardLocalDatasource {
  DashboardLocalDatasourceImpl();

  Box<UserStatsModel>? _statsBox;
  Box<EarnedAchievementModel>? _achievementsBox;

  /// Lazy getter for stats box with safety check
  Box<UserStatsModel> get _stats {
    if (_statsBox == null || !_statsBox!.isOpen) {
      throw StateError(
        'User stats box not initialized. Call initialize() first.',
      );
    }
    return _statsBox!;
  }

  /// Lazy getter for achievements box with safety check
  Box<EarnedAchievementModel> get _achievements {
    if (_achievementsBox == null || !_achievementsBox!.isOpen) {
      throw StateError(
        'Achievements box not initialized. Call initialize() first.',
      );
    }
    return _achievementsBox!;
  }

  @override
  Future<void> initialize() async {
    debugPrint('DashboardLocalDatasource: initializing...');

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(DashboardHiveTypeIds.userStatsModel)) {
      Hive.registerAdapter(UserStatsModelAdapter());
    }
    if (!Hive.isAdapterRegistered(DashboardHiveTypeIds.earnedAchievementModel)) {
      Hive.registerAdapter(EarnedAchievementModelAdapter());
    }

    // Open boxes
    _statsBox = await Hive.openBox<UserStatsModel>(
      DashboardStorageKeys.userStatsBox,
    );
    _achievementsBox = await Hive.openBox<EarnedAchievementModel>(
      DashboardStorageKeys.earnedAchievementsBox,
    );

    debugPrint('DashboardLocalDatasource: initialized successfully');
  }

  @override
  Future<UserStatsModel> getUserStats() async {
    final stats = _stats.get(DashboardStorageKeys.userStatsKey);
    if (stats == null) {
      // Return empty stats if none exist
      final emptyStats = UserStatsModel.empty();
      await saveUserStats(emptyStats);
      return emptyStats;
    }
    return stats;
  }

  @override
  Future<void> saveUserStats(UserStatsModel stats) async {
    await _stats.put(DashboardStorageKeys.userStatsKey, stats);
    debugPrint('DashboardLocalDatasource: saved stats - XP: ${stats.totalXp}, '
        'Streak: ${stats.currentStreak}');
  }

  @override
  Future<List<EarnedAchievementModel>> getEarnedAchievements() async {
    return _achievements.values.toList();
  }

  @override
  Future<bool> isAchievementEarned(String achievementId) async {
    return _achievements.values.any((a) => a.achievementId == achievementId);
  }

  @override
  Future<void> saveEarnedAchievement(EarnedAchievementModel achievement) async {
    await _achievements.put(achievement.achievementId, achievement);
    debugPrint(
      'DashboardLocalDatasource: saved earned achievement ${achievement.achievementId}',
    );
  }

  @override
  Future<void> clearAll() async {
    await _stats.clear();
    await _achievements.clear();
    debugPrint('DashboardLocalDatasource: cleared all data');
  }
}
