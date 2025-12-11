import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../domain/entities/emotion_challenge_session.dart';
import '../providers/emotion_challenge_providers.dart';
import '../widgets/emotion_history_card.dart';

/// Screen displaying the history of all emotion challenge sessions
///
/// Follows the design pattern from the chat history screen
class EmotionChallengeHistoryScreen extends ConsumerWidget {
  const EmotionChallengeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(emotionChallengeSessionsProvider);

    return Scaffold(
      body: GradientBackground(
        showGlow: false,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button and title row
                    Row(
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

                        // Title
                        Text(
                          'Emotion History',
                          style: AppTypography.headlineLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Subtitle with count
                    sessionsAsync.when(
                      data: (sessions) => Text(
                        '${sessions.length} session${sessions.length == 1 ? '' : 's'} completed',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      loading: () => Text(
                        'Loading sessions...',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      error: (error, stackTrace) => Text(
                        'Your emotion challenge history',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              const Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.borderSubtle,
              ),

              // Content
              Expanded(
                child: sessionsAsync.when(
                  data: (sessions) => sessions.isEmpty
                      ? _buildEmptyState(context)
                      : _buildSessionsList(context, sessions),
                  loading: () => _buildLoadingState(),
                  error: (error, stack) => _buildErrorState(context, ref, error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the list of sessions
  Widget _buildSessionsList(BuildContext context, List<EmotionChallengeSession> sessions) {
    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return EmotionHistoryCard(
          session: session,
          onTap: () {
            // Navigate to detail screen with session ID
            context.push(
              AppRoutes.emotionChallengeDetail,
              extra: session.id,
            );
          },
        );
      },
    );
  }

  /// Builds the empty state when no sessions exist
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                CupertinoIcons.heart,
                size: 40,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'No emotion challenges yet',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              'Complete your first emotion challenge\nto see your history here',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Go back to start challenge
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Start Your First Challenge',
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

  /// Builds the loading state
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  /// Builds the error state with retry option
  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            const Icon(
              CupertinoIcons.exclamationmark_circle,
              size: 64,
              color: AppColors.error,
            ),

            const SizedBox(height: 16),

            // Error message
            Text(
              'Failed to load history',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              error.toString(),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 24),

            // Retry button
            TextButton(
              onPressed: () {
                ref.invalidate(emotionChallengeSessionsProvider);
              },
              child: Text(
                'Try Again',
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
}
