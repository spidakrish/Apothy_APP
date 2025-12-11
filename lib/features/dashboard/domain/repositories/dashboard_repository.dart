import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/achievement.dart';
import '../entities/user_stats.dart';

/// Abstract repository interface for dashboard operations
///
/// Handles user statistics, achievements, XP, and streak tracking.
/// All data is stored locally using Hive.
abstract class DashboardRepository {
  // ============================================================================
  // User Stats Operations
  // ============================================================================

  /// Gets the current user statistics
  Future<Either<Failure, UserStats>> getUserStats();

  /// Awards XP to the user
  ///
  /// [amount] - The amount of XP to award
  /// [reason] - Optional reason for the XP award (for logging)
  Future<Either<Failure, UserStats>> awardXp(int amount, {String? reason});

  /// Updates the user's streak
  ///
  /// Should be called when the user opens the app or sends a message.
  /// Automatically calculates if the streak should continue or reset.
  Future<Either<Failure, UserStats>> updateStreak();

  /// Updates conversation and message counts
  ///
  /// [conversationCount] - Total number of conversations
  /// [messageCount] - Total number of messages sent
  Future<Either<Failure, UserStats>> updateActivityCounts({
    required int conversationCount,
    required int messageCount,
  });

  // ============================================================================
  // Achievement Operations
  // ============================================================================

  /// Gets all achievements with their earned status
  Future<Either<Failure, List<Achievement>>> getAchievements();

  /// Gets only the achievements that have been earned
  Future<Either<Failure, List<Achievement>>> getEarnedAchievements();

  /// Checks and unlocks any achievements based on current stats
  ///
  /// Returns list of newly unlocked achievements
  Future<Either<Failure, List<Achievement>>> checkAndUnlockAchievements();

  /// Unlocks a specific achievement by ID
  Future<Either<Failure, Achievement>> unlockAchievement(String achievementId);

  // ============================================================================
  // Utility Operations
  // ============================================================================

  /// Resets all dashboard data (for testing or user request)
  Future<Either<Failure, void>> resetAll();

  /// Initializes the dashboard storage
  Future<Either<Failure, void>> initialize();
}
