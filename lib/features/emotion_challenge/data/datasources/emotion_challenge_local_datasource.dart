import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/body_map_point_model.dart';
import '../models/emotion_challenge_session_model.dart';
import '../models/reflection_response_model.dart';

/// Storage keys for emotion challenge Hive boxes
abstract class EmotionChallengeStorageKeys {
  static const String sessionsBox = 'emotion_challenge_sessions';
}

/// Abstract interface for emotion challenge local storage operations
abstract class EmotionChallengeLocalDatasource {
  /// Initialize the datasource (open Hive boxes and register adapters)
  Future<void> initialize();

  /// Save an emotion challenge session
  Future<void> saveSession(EmotionChallengeSessionModel session);

  /// Get all emotion challenge sessions, sorted by completedAt descending
  Future<List<EmotionChallengeSessionModel>> getSessions();

  /// Get a single session by ID
  Future<EmotionChallengeSessionModel?> getSession(String sessionId);

  /// Delete a session
  Future<void> deleteSession(String sessionId);

  /// Get total number of completed sessions
  Future<int> getSessionCount();

  /// Clear all emotion challenge data
  Future<void> clearAll();
}

/// Implementation of EmotionChallengeLocalDatasource using Hive
class EmotionChallengeLocalDatasourceImpl
    implements EmotionChallengeLocalDatasource {
  EmotionChallengeLocalDatasourceImpl();

  Box<EmotionChallengeSessionModel>? _sessionsBox;

  /// Lazy getter for sessions box with safety check
  Box<EmotionChallengeSessionModel> get _sessions {
    if (_sessionsBox == null || !_sessionsBox!.isOpen) {
      throw StateError(
        'Emotion challenge sessions box not initialized. Call initialize() first.',
      );
    }
    return _sessionsBox!;
  }

  @override
  Future<void> initialize() async {
    debugPrint('EmotionChallengeLocalDatasource: initializing...');

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(
        EmotionChallengeHiveTypeIds.emotionChallengeSession)) {
      Hive.registerAdapter(EmotionChallengeSessionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(EmotionChallengeHiveTypeIds.bodyMapPoint)) {
      Hive.registerAdapter(BodyMapPointModelAdapter());
    }
    if (!Hive.isAdapterRegistered(
        EmotionChallengeHiveTypeIds.reflectionResponse)) {
      Hive.registerAdapter(ReflectionResponseModelAdapter());
    }

    // Open boxes
    _sessionsBox = await Hive.openBox<EmotionChallengeSessionModel>(
      EmotionChallengeStorageKeys.sessionsBox,
    );

    debugPrint('EmotionChallengeLocalDatasource: initialized successfully');
  }

  @override
  Future<void> saveSession(EmotionChallengeSessionModel session) async {
    debugPrint(
        'EmotionChallengeLocalDatasource: saving session ${session.id}');

    // Use session ID as the key
    await _sessions.put(session.id, session);

    debugPrint(
        'EmotionChallengeLocalDatasource: session ${session.id} saved successfully');
  }

  @override
  Future<List<EmotionChallengeSessionModel>> getSessions() async {
    debugPrint('EmotionChallengeLocalDatasource: fetching all sessions');

    final sessions = _sessions.values.toList();

    // Sort by completedAt descending (most recent first)
    sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    debugPrint(
        'EmotionChallengeLocalDatasource: found ${sessions.length} sessions');

    return sessions;
  }

  @override
  Future<EmotionChallengeSessionModel?> getSession(String sessionId) async {
    debugPrint(
        'EmotionChallengeLocalDatasource: fetching session $sessionId');

    final session = _sessions.get(sessionId);

    if (session == null) {
      debugPrint(
          'EmotionChallengeLocalDatasource: session $sessionId not found');
    } else {
      debugPrint(
          'EmotionChallengeLocalDatasource: session $sessionId found');
    }

    return session;
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    debugPrint(
        'EmotionChallengeLocalDatasource: deleting session $sessionId');

    await _sessions.delete(sessionId);

    debugPrint(
        'EmotionChallengeLocalDatasource: session $sessionId deleted');
  }

  @override
  Future<int> getSessionCount() async {
    final count = _sessions.length;
    debugPrint(
        'EmotionChallengeLocalDatasource: total session count: $count');
    return count;
  }

  @override
  Future<void> clearAll() async {
    debugPrint('EmotionChallengeLocalDatasource: clearing all data');

    await _sessions.clear();

    debugPrint('EmotionChallengeLocalDatasource: all data cleared');
  }
}
