import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../domain/entities/achievement.dart';
import 'providers/dashboard_providers.dart';

/// Dashboard screen - Points, achievements, progress
/// Shows user's gamification stats and achievements
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);

    // Listen for newly unlocked achievements to trigger confetti
    ref.listen<List<Achievement>>(
      newlyUnlockedAchievementsProvider,
      (previous, next) {
        if (next.isNotEmpty) {
          _confettiController.play();
          // Clear the notification after showing
          Future.delayed(const Duration(seconds: 3), () {
            ref.read(dashboardProvider.notifier).clearNewAchievements();
          });
        }
      },
    );

    return GradientBackground(
      showGlow: false,
      child: Stack(
        children: [
          SafeArea(
            child: dashboardState.when(
              data: (state) => _buildContent(context, state),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading dashboard',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Confetti overlay for achievement celebrations
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // straight down
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.primaryLight,
                AppColors.success,
                AppColors.warning,
                AppColors.info,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardState state) {
    final stats = state.userStats;
    final earnedAchievements = state.earnedAchievements;

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: AppTypography.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Your progress and achievements',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // XP Hero Card with Circular Progress
            _XpHeroCard(
              totalXp: stats.totalXp,
              level: stats.level,
              levelProgress: stats.levelProgress,
            ),
            const SizedBox(height: 16),

            // Streak Card
            _StatCard(
              title: 'Current Streak',
              value: stats.streakDisplay,
              subtitle: stats.longestStreak > 0
                  ? 'Best: ${stats.longestStreak} days'
                  : 'Start your streak today!',
              icon: Icons.local_fire_department_outlined,
              color: AppColors.warning,
            ),
            const SizedBox(height: 16),

            // Conversations Card
            _StatCard(
              title: 'Conversations',
              value: stats.totalConversations.toString(),
              subtitle: '${stats.totalMessages} messages sent',
              icon: Icons.chat_outlined,
              color: AppColors.info,
            ),
            const SizedBox(height: 32),

            // Achievements Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Achievements',
                  style: AppTypography.headlineSmall,
                ),
                Text(
                  '${earnedAchievements.length}/${Achievements.all.length}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (earnedAchievements.isEmpty)
              _buildEmptyAchievements()
            else
              _buildAchievementsList(state.achievements),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAchievements() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'No achievements yet',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Start chatting to earn achievements',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsList(List<Achievement> achievements) {
    // Sort: earned first, then by category
    final sortedAchievements = List<Achievement>.from(achievements)
      ..sort((a, b) {
        if (a.isEarned != b.isEarned) {
          return a.isEarned ? -1 : 1;
        }
        return a.category.index.compareTo(b.category.index);
      });

    return Column(
      children: sortedAchievements.map((achievement) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _AchievementCard(achievement: achievement),
        );
      }).toList(),
    );
  }
}

/// XP Hero Card with circular progress indicator
class _XpHeroCard extends StatelessWidget {
  const _XpHeroCard({
    required this.totalXp,
    required this.level,
    required this.levelProgress,
  });

  final int totalXp;
  final int level;
  final double levelProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          // Circular Progress Indicator
          CircularPercentIndicator(
            radius: 50.0,
            lineWidth: 8.0,
            percent: levelProgress.clamp(0.0, 1.0),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Lv',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
                Text(
                  '$level',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            progressColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 800,
          ),
          const SizedBox(width: 20),
          // XP Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total XP',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalXp',
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(levelProgress * 100).toInt()}% to Level ${level + 1}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // Star Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.star,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat card widget for displaying metrics
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: AppTypography.headlineSmall,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Achievement card widget
class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});

  final Achievement achievement;

  IconData get _iconData {
    // Map icon names to IconData
    switch (achievement.iconName) {
      case 'chat_bubble_outline':
        return Icons.chat_bubble_outline;
      case 'forum':
        return Icons.forum;
      case 'question_answer':
        return Icons.question_answer;
      case 'record_voice_over':
        return Icons.record_voice_over;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'military_tech':
        return Icons.military_tech;
      case 'star_outline':
        return Icons.star_outline;
      case 'star_half':
        return Icons.star_half;
      case 'star':
        return Icons.star;
      case 'textsms':
        return Icons.textsms;
      case 'message':
        return Icons.message;
      case 'mark_chat_read':
        return Icons.mark_chat_read;
      default:
        return Icons.emoji_events;
    }
  }

  Color get _categoryColor {
    switch (achievement.category) {
      case AchievementCategory.conversation:
        return AppColors.info;
      case AchievementCategory.streak:
        return AppColors.warning;
      case AchievementCategory.xp:
        return AppColors.primary;
      case AchievementCategory.milestone:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEarned = achievement.isEarned;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEarned
            ? AppColors.cardBackground
            : AppColors.cardBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEarned ? _categoryColor.withValues(alpha: 0.3) : AppColors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isEarned
                  ? _categoryColor.withValues(alpha: 0.15)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _iconData,
              color: isEarned ? _categoryColor : AppColors.textTertiary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isEarned ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: isEarned ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (isEarned) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: _categoryColor,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${achievement.xpReward}',
                    style: AppTypography.bodySmall.copyWith(
                      color: _categoryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Icon(
              Icons.lock_outline,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }
}
