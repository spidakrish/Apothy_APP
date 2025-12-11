import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';
import '../models/earned_achievement_model.dart';

/// Implementation of DashboardRepository using local Hive storage
class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({
    required this.localDatasource,
  });

  final DashboardLocalDatasource localDatasource;

  // ============================================================================
  // User Stats Operations
  // ============================================================================

  @override
  Future<Either<Failure, UserStats>> getUserStats() async {
    try {
      final statsModel = await localDatasource.getUserStats();
      return Right(statsModel.toEntity());
    } catch (e) {
      debugPrint('DashboardRepository: error getting stats: $e');
      return Left(DashboardFailure.loadFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserStats>> awardXp(int amount, {String? reason}) async {
    try {
      final currentStats = await localDatasource.getUserStats();

      final updatedStats = currentStats.copyWith(
        totalXp: currentStats.totalXp + amount,
      );

      await localDatasource.saveUserStats(updatedStats);

      debugPrint('DashboardRepository: awarded $amount XP${reason != null ? ' ($reason)' : ''}. '
          'Total: ${updatedStats.totalXp}');

      return Right(updatedStats.toEntity());
    } catch (e) {
      debugPrint('DashboardRepository: error awarding XP: $e');
      return Left(DashboardFailure.xpAwardFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserStats>> updateStreak() async {
    try {
      final currentStats = await localDatasource.getUserStats();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      int newStreak = currentStats.currentStreak;
      int newLongestStreak = currentStats.longestStreak;

      if (currentStats.lastActiveDate == null) {
        // First time user - start streak at 1
        newStreak = 1;
      } else {
        final lastActive = currentStats.lastActiveDate!;
        final lastActiveDay = DateTime(
          lastActive.year,
          lastActive.month,
          lastActive.day,
        );

        final daysDifference = today.difference(lastActiveDay).inDays;

        if (daysDifference == 0) {
          // Same day - no change to streak
          return Right(currentStats.toEntity());
        } else if (daysDifference == 1) {
          // Consecutive day - increment streak
          newStreak = currentStats.currentStreak + 1;
        } else {
          // Missed days - reset streak
          newStreak = 1;
        }
      }

      // Update longest streak if needed
      if (newStreak > newLongestStreak) {
        newLongestStreak = newStreak;
      }

      final updatedStats = currentStats.copyWith(
        currentStreak: newStreak,
        longestStreak: newLongestStreak,
        lastActiveDate: now,
      );

      await localDatasource.saveUserStats(updatedStats);

      debugPrint('DashboardRepository: updated streak to $newStreak days');

      return Right(updatedStats.toEntity());
    } catch (e) {
      debugPrint('DashboardRepository: error updating streak: $e');
      return Left(DashboardFailure.streakUpdateFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserStats>> updateActivityCounts({
    required int conversationCount,
    required int messageCount,
  }) async {
    try {
      final currentStats = await localDatasource.getUserStats();

      final updatedStats = currentStats.copyWith(
        totalConversations: conversationCount,
        totalMessages: messageCount,
      );

      await localDatasource.saveUserStats(updatedStats);

      return Right(updatedStats.toEntity());
    } catch (e) {
      debugPrint('DashboardRepository: error updating activity counts: $e');
      return Left(DashboardFailure.saveFailed(e.toString()));
    }
  }

  // ============================================================================
  // Achievement Operations
  // ============================================================================

  @override
  Future<Either<Failure, List<Achievement>>> getAchievements() async {
    try {
      final earnedAchievements = await localDatasource.getEarnedAchievements();
      final earnedIds = earnedAchievements.map((e) => e.achievementId).toSet();

      // Map all predefined achievements with their earned status
      final achievements = Achievements.all.map((achievement) {
        final earned = earnedAchievements.firstWhere(
          (e) => e.achievementId == achievement.id,
          orElse: () => EarnedAchievementModel(
            achievementId: '',
            earnedAt: DateTime.now(),
          ),
        );

        final isEarned = earnedIds.contains(achievement.id);

        return achievement.copyWith(
          isEarned: isEarned,
          earnedAt: isEarned ? earned.earnedAt : null,
        );
      }).toList();

      return Right(achievements);
    } catch (e) {
      debugPrint('DashboardRepository: error getting achievements: $e');
      return Left(DashboardFailure.loadFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Achievement>>> getEarnedAchievements() async {
    try {
      final earnedAchievements = await localDatasource.getEarnedAchievements();

      final achievements = earnedAchievements
          .map((earned) {
            final achievement = Achievements.getById(earned.achievementId);
            if (achievement == null) return null;
            return achievement.copyWith(
              isEarned: true,
              earnedAt: earned.earnedAt,
            );
          })
          .whereType<Achievement>()
          .toList();

      // Sort by earned date (most recent first)
      achievements.sort((a, b) =>
          (b.earnedAt ?? DateTime.now()).compareTo(a.earnedAt ?? DateTime.now()));

      return Right(achievements);
    } catch (e) {
      debugPrint('DashboardRepository: error getting earned achievements: $e');
      return Left(DashboardFailure.loadFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Achievement>>> checkAndUnlockAchievements() async {
    try {
      final currentStats = await localDatasource.getUserStats();
      final stats = currentStats.toEntity();
      final newlyUnlocked = <Achievement>[];

      for (final achievement in Achievements.all) {
        // Skip if already earned
        if (await localDatasource.isAchievementEarned(achievement.id)) {
          continue;
        }

        bool shouldUnlock = false;

        switch (achievement.category) {
          case AchievementCategory.conversation:
            shouldUnlock = stats.totalConversations >= achievement.requiredValue;
            break;
          case AchievementCategory.streak:
            shouldUnlock = stats.currentStreak >= achievement.requiredValue ||
                stats.longestStreak >= achievement.requiredValue;
            break;
          case AchievementCategory.xp:
            shouldUnlock = stats.totalXp >= achievement.requiredValue;
            break;
          case AchievementCategory.milestone:
            shouldUnlock = stats.totalMessages >= achievement.requiredValue;
            break;
        }

        if (shouldUnlock) {
          final result = await unlockAchievement(achievement.id);
          result.fold(
            (failure) => debugPrint('Failed to unlock ${achievement.id}: ${failure.message}'),
            (unlockedAchievement) {
              newlyUnlocked.add(unlockedAchievement);
              debugPrint('DashboardRepository: unlocked achievement: ${achievement.title}');
            },
          );
        }
      }

      return Right(newlyUnlocked);
    } catch (e) {
      debugPrint('DashboardRepository: error checking achievements: $e');
      return Left(DashboardFailure.loadFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Achievement>> unlockAchievement(String achievementId) async {
    try {
      final achievement = Achievements.getById(achievementId);
      if (achievement == null) {
        return Left(DashboardFailure.achievementNotFound());
      }

      // Check if already earned
      if (await localDatasource.isAchievementEarned(achievementId)) {
        // Return the achievement as already earned
        final earnedAchievements = await localDatasource.getEarnedAchievements();
        final earned = earnedAchievements.firstWhere(
          (e) => e.achievementId == achievementId,
        );
        return Right(achievement.copyWith(
          isEarned: true,
          earnedAt: earned.earnedAt,
        ));
      }

      final now = DateTime.now();

      // Save the earned achievement
      await localDatasource.saveEarnedAchievement(
        EarnedAchievementModel(
          achievementId: achievementId,
          earnedAt: now,
        ),
      );

      // Award XP for the achievement
      if (achievement.xpReward > 0) {
        await awardXp(achievement.xpReward, reason: 'Achievement: ${achievement.title}');
      }

      return Right(achievement.copyWith(
        isEarned: true,
        earnedAt: now,
      ));
    } catch (e) {
      debugPrint('DashboardRepository: error unlocking achievement: $e');
      return Left(DashboardFailure.saveFailed(e.toString()));
    }
  }

  // ============================================================================
  // Utility Operations
  // ============================================================================

  @override
  Future<Either<Failure, void>> resetAll() async {
    try {
      await localDatasource.clearAll();
      return const Right(null);
    } catch (e) {
      debugPrint('DashboardRepository: error resetting: $e');
      return Left(DashboardFailure.saveFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      await localDatasource.initialize();
      return const Right(null);
    } catch (e) {
      debugPrint('DashboardRepository: error initializing: $e');
      return Left(DashboardFailure.notInitialized());
    }
  }
}
