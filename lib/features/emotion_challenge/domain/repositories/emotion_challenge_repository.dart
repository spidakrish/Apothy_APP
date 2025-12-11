import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/emotion_challenge_session.dart';

/// Abstract repository interface for emotion challenge operations
///
/// Handles saving, retrieving, and managing emotion challenge sessions.
/// All data is stored locally using Hive.
abstract class EmotionChallengeRepository {
  // ============================================================================
  // Session Operations
  // ============================================================================

  /// Saves a completed emotion challenge session
  ///
  /// [session] - The completed emotion challenge session to save
  /// Returns the saved session or a Failure if something goes wrong
  Future<Either<Failure, EmotionChallengeSession>> saveSession(
    EmotionChallengeSession session,
  );

  /// Gets all emotion challenge sessions
  ///
  /// Returns sessions sorted by completion date (most recent first)
  Future<Either<Failure, List<EmotionChallengeSession>>> getSessionHistory();

  /// Gets a single session by ID
  ///
  /// [sessionId] - The unique identifier of the session
  /// Returns the session or a Failure if not found
  Future<Either<Failure, EmotionChallengeSession>> getSession(String sessionId);

  /// Deletes a session
  ///
  /// [sessionId] - The unique identifier of the session to delete
  Future<Either<Failure, void>> deleteSession(String sessionId);

  /// Gets the total number of completed sessions
  Future<Either<Failure, int>> getSessionCount();

  // ============================================================================
  // Utility Operations
  // ============================================================================

  /// Clears all emotion challenge data
  ///
  /// Used for testing or when the user requests data deletion
  Future<Either<Failure, void>> clearAll();

  /// Initializes the repository storage
  ///
  /// Must be called before any other operations
  Future<Either<Failure, void>> initialize();
}
