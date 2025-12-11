import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/emotion_challenge_session.dart';

/// A card displaying an emotion challenge session in the history list
///
/// Follows the design pattern from the chat history screen's conversation items
class EmotionHistoryCard extends StatelessWidget {
  const EmotionHistoryCard({
    super.key,
    required this.session,
    required this.onTap,
  });

  final EmotionChallengeSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            // Emotion icon container with colored background
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: session.emotion.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: session.emotion.color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  _getEmotionEmoji(session.emotion.id),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Emotion name and details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emotion name with intensity
                  Text(
                    '${session.emotion.name} - ${_capitalize(session.emotion.intensity.name)}',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Body regions and reflection count
                  Text(
                    _buildSubtitle(),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Date and XP badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Date
                Text(
                  _formatDate(session.completedAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),

                const SizedBox(height: 4),

                // XP earned badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+${session.xpEarned} XP',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),

            // Chevron icon
            const Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the subtitle showing body regions and reflections
  String _buildSubtitle() {
    final regions = session.affectedRegions;
    final regionsCount = regions.length;
    final reflectionsCount = session.answeredReflectionsCount;

    if (regionsCount == 0 && reflectionsCount == 0) {
      return 'No details';
    }

    final parts = <String>[];

    if (regionsCount > 0) {
      if (regionsCount == 1) {
        parts.add(regions.first);
      } else if (regionsCount == 2) {
        parts.add('${regions[0]}, ${regions[1]}');
      } else {
        parts.add('${regions[0]}, ${regions[1]}, +${regionsCount - 2}');
      }
    }

    if (reflectionsCount > 0) {
      parts.add('$reflectionsCount reflection${reflectionsCount == 1 ? '' : 's'}');
    }

    return parts.join(' • ');
  }

  /// Formats the date following the history screen pattern
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDate = DateTime(date.year, date.month, date.day);

    // Today: show time
    if (sessionDate == today) {
      return DateFormat('h:mm a').format(date);
    }

    // Yesterday
    if (sessionDate == yesterday) {
      return 'Yesterday';
    }

    // This week: show day name
    final difference = today.difference(sessionDate).inDays;
    if (difference < 7) {
      return DateFormat('EEE').format(date); // Mon, Tue, etc.
    }

    // Older: show date
    return DateFormat('M/d').format(date); // 3/15
  }

  /// Gets emoji for emotion ID
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
        return '🎭'; // Generic emotion mask
    }
  }

  /// Capitalizes the first letter of a string
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
