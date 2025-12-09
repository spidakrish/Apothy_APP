import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/ai_service.dart';

// =============================================================================
// AI Service Provider
// =============================================================================

/// Provider for AIChatService
///
/// This creates a singleton instance of the AI service that is
/// automatically disposed when no longer needed.
///
/// DEVELOPER: The service is configured via AIConfig.
/// Set AIConfig.useMockResponses = false when backend is ready.
final aiServiceProvider = Provider<AIChatService>((ref) {
  final service = AIChatService();

  // Auto-dispose when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

// =============================================================================
// AI Response Style Provider
// =============================================================================

/// Current AI response style preference
///
/// Values: 'creative', 'balanced', 'precise'
/// This affects the temperature parameter sent to the AI.
final aiResponseStyleProvider = StateProvider<String>((ref) {
  return 'balanced'; // Default style
});

// =============================================================================
// AI Loading State Provider
// =============================================================================

/// Whether an AI response is currently being generated
///
/// This is separate from chat's isSending state to allow
/// more granular control over loading indicators.
final isAIRespondingProvider = StateProvider<bool>((ref) {
  return false;
});
