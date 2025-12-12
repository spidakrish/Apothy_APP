import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../subscription/presentation/providers/subscription_providers.dart';
import '../../domain/entities/emotion_challenge_session.dart';
import '../../domain/repositories/emotion_challenge_repository.dart';
import '../datasources/emotion_challenge_local_datasource.dart';
import '../models/emotion_challenge_session_model.dart';

/// Implementation of EmotionChallengeRepository using local Hive storage
class EmotionChallengeRepositoryImpl implements EmotionChallengeRepository {
  EmotionChallengeRepositoryImpl({
    required this.localDatasource,
    required this.ref,
  });

  final EmotionChallengeLocalDatasource localDatasource;
  final Ref ref;

  @override
  Future<Either<Failure, EmotionChallengeSession>> saveSession(
    EmotionChallengeSession session,
  ) async {
    try {
      final model = EmotionChallengeSessionModel.fromEntity(session);
      await localDatasource.saveSession(model);
      return Right(session);
    } catch (e) {
      return Left(
        StorageFailure(
          message: 'Failed to save emotion challenge session: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<EmotionChallengeSession>>>
      getSessionHistory() async {
    try {
      final models = await localDatasource.getSessions();
      final sessions = models.map((m) => m.toEntity()).toList();
      return Right(sessions);
    } catch (e) {
      return Left(
        StorageFailure(
          message: 'Failed to load emotion challenge history: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, EmotionChallengeSession>> getSession(
    String sessionId,
  ) async {
    try {
      final model = await localDatasource.getSession(sessionId);
      if (model == null) {
        return Left(
          StorageFailure(
            message: 'Emotion challenge session not found: $sessionId',
          ),
        );
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(
        StorageFailure(
          message: 'Failed to load emotion challenge session: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    try {
      await localDatasource.deleteSession(sessionId);
      return const Right(null);
    } catch (e) {
      return Left(
        StorageFailure(
          message:
              'Failed to delete emotion challenge session: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getSessionCount() async {
    try {
      final count = await localDatasource.getSessionCount();
      return Right(count);
    } catch (e) {
      return Left(
        StorageFailure(
          message:
              'Failed to get emotion challenge session count: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearAll() async {
    try {
      await localDatasource.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(
        StorageFailure(
          message: 'Failed to clear emotion challenge data: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> canStartChallenge() async {
    try {
      // Check if user has premium subscription
      final isPremium = ref.read(isPremiumProvider);

      // Premium users have unlimited challenges
      if (isPremium) {
        return const Right(true);
      }

      // Free users are limited to 5 challenges per month
      final challengesThisMonth = await getChallengesThisMonth();

      return challengesThisMonth.fold(
        (failure) => Left(failure),
        (count) => Right(count < 5),
      );
    } catch (e) {
      return Left(
        StorageFailure(
          message: 'Failed to check challenge limit: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getChallengesThisMonth() async {
    try {
      // Get all sessions
      final sessions = await localDatasource.getSessions();

      // Get first day of current month
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      // Count sessions completed this month
      final thisMonthCount = sessions
          .where((session) => session.startedAt.isAfter(firstDayOfMonth))
          .length;

      return Right(thisMonthCount);
    } catch (e) {
      return Left(
        StorageFailure(
          message: 'Failed to count challenges this month: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      await localDatasource.initialize();
      return const Right(null);
    } catch (e) {
      return Left(
        StorageFailure(
          message:
              'Failed to initialize emotion challenge repository: ${e.toString()}',
        ),
      );
    }
  }
}
