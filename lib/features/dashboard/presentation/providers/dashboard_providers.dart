import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/local_notification_service.dart';
import '../../../chat/domain/repositories/chat_repository.dart';
import '../../../chat/presentation/providers/chat_providers.dart';
import '../../data/datasources/dashboard_local_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';

// ============================================================================
// Datasource & Repository Providers
// ============================================================================

/// Provider for the dashboard local datasource
final dashboardLocalDatasourceProvider = Provider<DashboardLocalDatasource>((ref) {
  return DashboardLocalDatasourceImpl();
});

/// Provider for the dashboard repository
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final localDatasource = ref.watch(dashboardLocalDatasourceProvider);
  return DashboardRepositoryImpl(localDatasource: localDatasource);
});

// ============================================================================
// Dashboard State
// ============================================================================

/// State class for the dashboard
class DashboardState {
  const DashboardState({
    required this.userStats,
    required this.achievements,
    required this.earnedAchievements,
    this.isLoading = false,
    this.newlyUnlockedAchievements = const [],
    this.failure,
  });

  /// Factory for initial state
  factory DashboardState.initial() => DashboardState(
        userStats: UserStats.empty,
        achievements: const [],
        earnedAchievements: const [],
      );

  final UserStats userStats;
  final List<Achievement> achievements;
  final List<Achievement> earnedAchievements;
  final bool isLoading;
  final List<Achievement> newlyUnlockedAchievements;
  final dynamic failure;

  bool get hasStats => userStats.isNotEmpty;
  bool get hasAchievements => achievements.isNotEmpty;
  bool get hasEarnedAchievements => earnedAchievements.isNotEmpty;
  bool get hasError => failure != null;
  bool get hasNewAchievements => newlyUnlockedAchievements.isNotEmpty;

  DashboardState copyWith({
    UserStats? userStats,
    List<Achievement>? achievements,
    List<Achievement>? earnedAchievements,
    bool? isLoading,
    List<Achievement>? newlyUnlockedAchievements,
    dynamic failure,
  }) {
    return DashboardState(
      userStats: userStats ?? this.userStats,
      achievements: achievements ?? this.achievements,
      earnedAchievements: earnedAchievements ?? this.earnedAchievements,
      isLoading: isLoading ?? this.isLoading,
      newlyUnlockedAchievements:
          newlyUnlockedAchievements ?? this.newlyUnlockedAchievements,
      failure: failure,
    );
  }
}

// ============================================================================
// Dashboard Notifier
// ============================================================================

/// AsyncNotifier for managing dashboard state
class DashboardNotifier extends AsyncNotifier<DashboardState> {
  late DashboardRepository _repository;
  late DashboardLocalDatasource _localDatasource;
  late ChatRepository _chatRepository;

  @override
  Future<DashboardState> build() async {
    _repository = ref.watch(dashboardRepositoryProvider);
    _localDatasource = ref.watch(dashboardLocalDatasourceProvider);
    _chatRepository = ref.watch(chatRepositoryProvider);

    // Initialize the datasource
    await _localDatasource.initialize();

    return _loadDashboardData();
  }

  /// Load all dashboard data
  Future<DashboardState> _loadDashboardData() async {
    debugPrint('DashboardNotifier: loading dashboard data...');

    // Sync with chat stats first
    await _syncWithChatStats();

    // Update streak
    await _repository.updateStreak();

    // Check for new achievements
    await _repository.checkAndUnlockAchievements();

    // Load user stats
    final statsResult = await _repository.getUserStats();
    final stats = statsResult.fold(
      (failure) {
        debugPrint('DashboardNotifier: error loading stats: ${failure.message}');
        return UserStats.empty;
      },
      (stats) => stats,
    );

    // Load achievements
    final achievementsResult = await _repository.getAchievements();
    final achievements = achievementsResult.fold(
      (failure) {
        debugPrint('DashboardNotifier: error loading achievements: ${failure.message}');
        return <Achievement>[];
      },
      (achievements) => achievements,
    );

    // Load earned achievements
    final earnedResult = await _repository.getEarnedAchievements();
    final earnedAchievements = earnedResult.fold(
      (failure) => <Achievement>[],
      (earned) => earned,
    );

    debugPrint('DashboardNotifier: loaded stats - XP: ${stats.totalXp}, '
        'Streak: ${stats.currentStreak}, '
        'Conversations: ${stats.totalConversations}, '
        'Messages: ${stats.totalMessages}');
    debugPrint('DashboardNotifier: earned ${earnedAchievements.length} achievements');

    return DashboardState(
      userStats: stats,
      achievements: achievements,
      earnedAchievements: earnedAchievements,
    );
  }

  /// Sync dashboard stats with chat repository stats
  Future<void> _syncWithChatStats() async {
    try {
      final chatStatsResult = await _chatRepository.getStats();
      chatStatsResult.fold(
        (failure) {
          debugPrint('DashboardNotifier: error syncing chat stats: ${failure.message}');
        },
        (chatStats) async {
          await _repository.updateActivityCounts(
            conversationCount: chatStats.totalConversations,
            messageCount: chatStats.totalMessages,
          );
        },
      );
    } catch (e) {
      debugPrint('DashboardNotifier: error syncing with chat: $e');
    }
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _loadDashboardData());
  }

  /// Award XP to the user
  Future<void> awardXp(int amount, {String? reason}) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final result = await _repository.awardXp(amount, reason: reason);

    result.fold(
      (failure) {
        debugPrint('DashboardNotifier: error awarding XP: ${failure.message}');
      },
      (updatedStats) async {
        // Check for new achievements after XP award
        final newAchievementsResult = await _repository.checkAndUnlockAchievements();

        final newlyUnlocked = newAchievementsResult.fold(
          (failure) => <Achievement>[],
          (achievements) => achievements,
        );

        // Trigger local notifications for newly unlocked achievements
        for (final achievement in newlyUnlocked) {
          await LocalNotificationService.instance.showAchievementUnlocked(
            achievementTitle: achievement.title,
            achievementDescription: achievement.description,
            achievementId: achievement.id.hashCode,
          );
        }

        // Reload achievements list
        final achievementsResult = await _repository.getAchievements();
        final achievements = achievementsResult.fold(
          (failure) => currentState.achievements,
          (list) => list,
        );

        final earnedResult = await _repository.getEarnedAchievements();
        final earnedAchievements = earnedResult.fold(
          (failure) => currentState.earnedAchievements,
          (list) => list,
        );

        state = AsyncValue.data(currentState.copyWith(
          userStats: updatedStats,
          achievements: achievements,
          earnedAchievements: earnedAchievements,
          newlyUnlockedAchievements: newlyUnlocked,
        ));
      },
    );
  }

  /// Record a message sent by the user (awards XP and updates stats)
  Future<void> recordMessageSent() async {
    await awardXp(10, reason: 'Message sent');
    await _syncWithChatStats();
    await refresh();
  }

  /// Record an AI response received (awards XP)
  Future<void> recordAiResponse() async {
    await awardXp(5, reason: 'AI response received');
  }

  /// Clear the newly unlocked achievements notification
  void clearNewAchievements() {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(
        newlyUnlockedAchievements: [],
      ));
    }
  }

  /// Reset all dashboard data (for testing)
  Future<void> resetAll() async {
    await _repository.resetAll();
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _loadDashboardData());
  }
}

// ============================================================================
// Main Dashboard Provider
// ============================================================================

/// Main provider for dashboard state management
final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardState>(
  DashboardNotifier.new,
);

// ============================================================================
// Convenience Providers (for optimized rebuilds)
// ============================================================================

/// Provider for just the user stats
final userStatsProvider = Provider<UserStats>((ref) {
  final dashboardState = ref.watch(dashboardProvider);
  return dashboardState.maybeWhen(
    data: (state) => state.userStats,
    orElse: () => UserStats.empty,
  );
});

/// Provider for total XP
final totalXpProvider = Provider<int>((ref) {
  return ref.watch(userStatsProvider).totalXp;
});

/// Provider for current streak
final currentStreakProvider = Provider<int>((ref) {
  return ref.watch(userStatsProvider).currentStreak;
});

/// Provider for conversation count
final conversationCountProvider = Provider<int>((ref) {
  return ref.watch(userStatsProvider).totalConversations;
});

/// Provider for earned achievements list
final earnedAchievementsProvider = Provider<List<Achievement>>((ref) {
  final dashboardState = ref.watch(dashboardProvider);
  return dashboardState.maybeWhen(
    data: (state) => state.earnedAchievements,
    orElse: () => [],
  );
});

/// Provider for all achievements with status
final allAchievementsProvider = Provider<List<Achievement>>((ref) {
  final dashboardState = ref.watch(dashboardProvider);
  return dashboardState.maybeWhen(
    data: (state) => state.achievements,
    orElse: () => [],
  );
});

/// Provider for newly unlocked achievements
final newlyUnlockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  final dashboardState = ref.watch(dashboardProvider);
  return dashboardState.maybeWhen(
    data: (state) => state.newlyUnlockedAchievements,
    orElse: () => [],
  );
});

/// Provider for dashboard loading state
final isDashboardLoadingProvider = Provider<bool>((ref) {
  final dashboardState = ref.watch(dashboardProvider);
  return dashboardState.isLoading;
});
