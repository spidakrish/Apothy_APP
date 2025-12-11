import 'package:equatable/equatable.dart';

/// Achievement category types
enum AchievementCategory {
  conversation,
  streak,
  xp,
  milestone,
}

/// An achievement that can be earned by the user
class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.category,
    required this.requiredValue,
    this.isEarned = false,
    this.earnedAt,
    this.xpReward = 0,
  });

  /// Unique identifier for the achievement
  final String id;

  /// Display title of the achievement
  final String title;

  /// Description of how to earn the achievement
  final String description;

  /// Icon name (Material Icons name)
  final String iconName;

  /// Category of the achievement
  final AchievementCategory category;

  /// Value required to unlock (e.g., 5 conversations, 7 day streak)
  final int requiredValue;

  /// Whether the user has earned this achievement
  final bool isEarned;

  /// When the achievement was earned (null if not earned)
  final DateTime? earnedAt;

  /// XP reward for earning this achievement
  final int xpReward;

  /// Check if achievement is not earned
  bool get isLocked => !isEarned;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        iconName,
        category,
        requiredValue,
        isEarned,
        earnedAt,
        xpReward,
      ];

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    AchievementCategory? category,
    int? requiredValue,
    bool? isEarned,
    DateTime? earnedAt,
    int? xpReward,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      category: category ?? this.category,
      requiredValue: requiredValue ?? this.requiredValue,
      isEarned: isEarned ?? this.isEarned,
      earnedAt: earnedAt ?? this.earnedAt,
      xpReward: xpReward ?? this.xpReward,
    );
  }
}

/// Predefined achievements available in the app
class Achievements {
  Achievements._();

  /// All available achievements
  static List<Achievement> get all => [
        // Conversation achievements
        const Achievement(
          id: 'first_chat',
          title: 'First Steps',
          description: 'Start your first conversation',
          iconName: 'chat_bubble_outline',
          category: AchievementCategory.conversation,
          requiredValue: 1,
          xpReward: 50,
        ),
        const Achievement(
          id: 'conversations_5',
          title: 'Getting Started',
          description: 'Have 5 conversations',
          iconName: 'forum',
          category: AchievementCategory.conversation,
          requiredValue: 5,
          xpReward: 100,
        ),
        const Achievement(
          id: 'conversations_25',
          title: 'Regular',
          description: 'Have 25 conversations',
          iconName: 'question_answer',
          category: AchievementCategory.conversation,
          requiredValue: 25,
          xpReward: 250,
        ),
        const Achievement(
          id: 'conversations_100',
          title: 'Conversationalist',
          description: 'Have 100 conversations',
          iconName: 'record_voice_over',
          category: AchievementCategory.conversation,
          requiredValue: 100,
          xpReward: 500,
        ),

        // Streak achievements
        const Achievement(
          id: 'streak_3',
          title: 'Warming Up',
          description: 'Maintain a 3-day streak',
          iconName: 'local_fire_department',
          category: AchievementCategory.streak,
          requiredValue: 3,
          xpReward: 75,
        ),
        const Achievement(
          id: 'streak_7',
          title: 'On Fire',
          description: 'Maintain a 7-day streak',
          iconName: 'whatshot',
          category: AchievementCategory.streak,
          requiredValue: 7,
          xpReward: 150,
        ),
        const Achievement(
          id: 'streak_30',
          title: 'Dedicated',
          description: 'Maintain a 30-day streak',
          iconName: 'military_tech',
          category: AchievementCategory.streak,
          requiredValue: 30,
          xpReward: 500,
        ),

        // XP achievements
        const Achievement(
          id: 'xp_100',
          title: 'Rising Star',
          description: 'Earn 100 XP',
          iconName: 'star_outline',
          category: AchievementCategory.xp,
          requiredValue: 100,
          xpReward: 25,
        ),
        const Achievement(
          id: 'xp_500',
          title: 'Shining Bright',
          description: 'Earn 500 XP',
          iconName: 'star_half',
          category: AchievementCategory.xp,
          requiredValue: 500,
          xpReward: 50,
        ),
        const Achievement(
          id: 'xp_1000',
          title: 'Superstar',
          description: 'Earn 1000 XP',
          iconName: 'star',
          category: AchievementCategory.xp,
          requiredValue: 1000,
          xpReward: 100,
        ),

        // Message milestones
        const Achievement(
          id: 'messages_10',
          title: 'Chatty',
          description: 'Send 10 messages',
          iconName: 'textsms',
          category: AchievementCategory.milestone,
          requiredValue: 10,
          xpReward: 50,
        ),
        const Achievement(
          id: 'messages_100',
          title: 'Talkative',
          description: 'Send 100 messages',
          iconName: 'message',
          category: AchievementCategory.milestone,
          requiredValue: 100,
          xpReward: 200,
        ),
        const Achievement(
          id: 'messages_500',
          title: 'Social Butterfly',
          description: 'Send 500 messages',
          iconName: 'mark_chat_read',
          category: AchievementCategory.milestone,
          requiredValue: 500,
          xpReward: 500,
        ),
      ];

  /// Get achievement by ID
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
