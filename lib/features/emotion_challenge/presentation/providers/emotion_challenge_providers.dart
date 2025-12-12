import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/emotion_challenge_local_datasource.dart';
import '../../data/repositories/emotion_challenge_repository_impl.dart';
import '../../domain/entities/emotion_challenge_session.dart';
import '../../domain/repositories/emotion_challenge_repository.dart';

// =============================================================================
// Datasource Provider
// =============================================================================

/// Provider for the emotion challenge local datasource
final emotionChallengeLocalDatasourceProvider =
    Provider<EmotionChallengeLocalDatasource>((ref) {
  return EmotionChallengeLocalDatasourceImpl();
});

// =============================================================================
// Repository Provider
// =============================================================================

/// Provider for the emotion challenge repository
final emotionChallengeRepositoryProvider =
    Provider<EmotionChallengeRepository>((ref) {
  return EmotionChallengeRepositoryImpl(
    localDatasource: ref.watch(emotionChallengeLocalDatasourceProvider),
    ref: ref,
  );
});

// =============================================================================
// Session History Provider
// =============================================================================

/// Provider for the list of all emotion challenge sessions (for history screen)
final emotionChallengeSessionsProvider =
    FutureProvider<List<EmotionChallengeSession>>((ref) async {
  final repository = ref.watch(emotionChallengeRepositoryProvider);
  final datasource = ref.watch(emotionChallengeLocalDatasourceProvider);

  // Ensure initialized
  await datasource.initialize();

  final result = await repository.getSessionHistory();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (sessions) => sessions,
  );
});

/// Provider for a single session by ID
final emotionChallengeSessionProvider =
    FutureProvider.family<EmotionChallengeSession, String>((ref, sessionId) async {
  final repository = ref.watch(emotionChallengeRepositoryProvider);
  final datasource = ref.watch(emotionChallengeLocalDatasourceProvider);

  // Ensure initialized
  await datasource.initialize();

  final result = await repository.getSession(sessionId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (session) => session,
  );
});
