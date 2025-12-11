import 'package:equatable/equatable.dart';

/// User statistics for the dashboard
///
/// Tracks XP points, streak days, and conversation counts.
/// All data is stored locally in Hive.
class UserStats extends Equatable {
  const UserStats({
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalConversations,
    required this.totalMessages,
    required this.lastActiveDate,
  });

  /// Total XP points earned by the user
  final int totalXp;

  /// Current consecutive days streak
  final int currentStreak;

  /// Longest streak ever achieved
  final int longestStreak;

  /// Total number of conversations started
  final int totalConversations;

  /// Total number of messages sent
  final int totalMessages;

  /// Last date the user was active (used for streak calculation)
  final DateTime? lastActiveDate;

  /// Empty/initial stats instance
  static UserStats empty = UserStats(
    totalXp: 0,
    currentStreak: 0,
    longestStreak: 0,
    totalConversations: 0,
    totalMessages: 0,
    lastActiveDate: null,
  );

  /// Check if stats are empty/initial
  bool get isEmpty => totalXp == 0 && totalMessages == 0;
  bool get isNotEmpty => !isEmpty;

  /// Calculate user level based on XP
  /// Level formula: Level = floor(sqrt(XP / 100)) + 1
  int get level => (totalXp / 100).floor() + 1;

  /// XP required for next level
  int get xpForNextLevel => (level * level) * 100;

  /// XP progress towards next level (0.0 to 1.0)
  double get levelProgress {
    final currentLevelXp = ((level - 1) * (level - 1)) * 100;
    final xpInCurrentLevel = totalXp - currentLevelXp;
    final xpNeededForLevel = xpForNextLevel - currentLevelXp;
    return xpInCurrentLevel / xpNeededForLevel;
  }

  /// Format streak for display
  String get streakDisplay =>
      currentStreak == 1 ? '1 day' : '$currentStreak days';

  @override
  List<Object?> get props => [
        totalXp,
        currentStreak,
        longestStreak,
        totalConversations,
        totalMessages,
        lastActiveDate,
      ];

  UserStats copyWith({
    int? totalXp,
    int? currentStreak,
    int? longestStreak,
    int? totalConversations,
    int? totalMessages,
    DateTime? lastActiveDate,
  }) {
    return UserStats(
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalConversations: totalConversations ?? this.totalConversations,
      totalMessages: totalMessages ?? this.totalMessages,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}
