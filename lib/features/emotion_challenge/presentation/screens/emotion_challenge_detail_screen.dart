import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../domain/entities/emotion_challenge_session.dart';
import '../providers/emotion_challenge_providers.dart';
import '../widgets/body_map.dart';

/// Screen displaying detailed information about a single emotion challenge session
class EmotionChallengeDetailScreen extends ConsumerWidget {
  const EmotionChallengeDetailScreen({
    super.key,
    required this.sessionId,
  });

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(emotionChallengeSessionProvider(sessionId));

    return Scaffold(
      body: GradientBackground(
        showGlow: false,
        child: SafeArea(
          child: sessionAsync.when(
            data: (session) => _buildContent(context, session),
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(context, error),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, EmotionChallengeSession session) {
    return Column(
      children: [
        // Header with back button
        _buildHeader(context, session),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session summary card
                _buildSummaryCard(session),

                const SizedBox(height: 24),

                // Metrics grid
                _buildMetricsGrid(session),

                const SizedBox(height: 24),

                // Body map section
                if (session.bodyMapPoints.isNotEmpty) ...[
                  _buildBodyMapSection(session),
                  const SizedBox(height: 24),
                ],

                // Reflections section
                if (session.reflections.isNotEmpty) ...[
                  _buildReflectionsSection(session),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, EmotionChallengeSession session) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderSubtle,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CupertinoIcons.back,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Session title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.emotion.name} - ${_capitalize(session.emotion.intensity.name)}',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  DateFormat('MMM d, yyyy • h:mm a').format(session.completedAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(EmotionChallengeSession session) {
    final durationMinutes = session.duration.inMinutes;
    final durationSeconds = session.duration.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: session.emotion.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Emotion icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: session.emotion.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Text(
                _getEmotionEmoji(session.emotion.id),
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Emotion name
          Text(
            session.emotion.name,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          // Intensity level
          Text(
            _capitalize(session.emotion.intensity.name),
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          // Duration and XP row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Duration
              _buildInfoChip(
                icon: CupertinoIcons.clock,
                label: '$durationMinutes:${durationSeconds.toString().padLeft(2, '0')}',
                color: AppColors.info,
              ),

              const SizedBox(width: 12),

              // XP earned
              _buildInfoChip(
                icon: Icons.star,
                label: '+${session.xpEarned} XP',
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(EmotionChallengeSession session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Metrics',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                label: 'CBT Score',
                value: session.cbtScore.toString(),
                icon: Icons.psychology,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildMetricCard(
                label: 'Body Regions',
                value: session.affectedRegions.length.toString(),
                icon: CupertinoIcons.person,
                color: AppColors.warning,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                label: 'Reflections',
                value: '${session.answeredReflectionsCount}/${session.reflections.length}',
                icon: CupertinoIcons.bubble_left_bubble_right,
                color: AppColors.info,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildMetricCard(
                label: 'Duration',
                value: '${session.duration.inMinutes}m',
                icon: CupertinoIcons.time,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMapSection(EmotionChallengeSession session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Body Map',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Areas where you felt this emotion',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 16),

        // Container for body map
        Container(
          height: 400,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderSubtle,
            ),
          ),
          child: BodyMap(
            emotion: session.emotion,
            initialData: BodyMapData(
              emotion: session.emotion,
              points: session.bodyMapPoints,
              timestamp: session.completedAt,
            ),
            brushIntensity: 0.7,
            onMapUpdated: (data) {
              // Read-only view, no updates
            },
          ),
        ),

        const SizedBox(height: 12),

        // Affected regions list
        if (session.affectedRegions.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: session.affectedRegions.map((region) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: session.emotion.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: session.emotion.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _capitalize(region),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildReflectionsSection(EmotionChallengeSession session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reflections',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Your thoughts and insights',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 16),

        ...session.reflections.asMap().entries.map((entry) {
          final index = entry.key;
          final reflection = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderSubtle,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question number and text
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        reflection.question,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Response
                if (reflection.isAnswered && reflection.response.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      reflection.response,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  )
                else
                  Text(
                    'Not answered',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_circle,
              size: 64,
              color: AppColors.error,
            ),

            const SizedBox(height: 16),

            Text(
              'Failed to load session',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              error.toString(),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Go Back',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmotionEmoji(String emotionId) {
    switch (emotionId) {
      case 'joy':
        return '😊';
      case 'trust':
        return '🤝';
      case 'fear':
        return '😰';
      case 'surprise':
        return '😲';
      case 'sadness':
        return '😢';
      case 'disgust':
        return '🤢';
      case 'anger':
        return '😠';
      case 'anticipation':
        return '🤔';
      case 'love':
        return '❤️';
      case 'submission':
        return '🙏';
      case 'awe':
        return '😮';
      case 'disapproval':
        return '😞';
      case 'remorse':
        return '😔';
      case 'contempt':
        return '😒';
      case 'aggressiveness':
        return '😤';
      case 'optimism':
        return '🌟';
      default:
        return '🎭';
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
