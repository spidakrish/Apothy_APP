import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/speech_service.dart';

/// State for speech recognition
class SpeechState {
  const SpeechState({
    this.isAvailable = false,
    this.isListening = false,
    this.recognizedText = '',
    this.error,
  });

  /// Whether speech recognition is available on this device
  final bool isAvailable;

  /// Whether currently listening for speech
  final bool isListening;

  /// The recognized text (updated in real-time)
  final String recognizedText;

  /// Error message if something went wrong
  final String? error;

  SpeechState copyWith({
    bool? isAvailable,
    bool? isListening,
    String? recognizedText,
    String? error,
  }) {
    return SpeechState(
      isAvailable: isAvailable ?? this.isAvailable,
      isListening: isListening ?? this.isListening,
      recognizedText: recognizedText ?? this.recognizedText,
      error: error,
    );
  }
}

/// Provider for the speech service singleton
final speechServiceProvider = Provider<SpeechService>((ref) {
  final service = SpeechService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Notifier for managing speech recognition state
class SpeechNotifier extends StateNotifier<SpeechState> {
  SpeechNotifier(this._service) : super(const SpeechState());

  final SpeechService _service;

  /// Initialize speech recognition
  Future<void> initialize() async {
    final available = await _service.initialize();
    state = state.copyWith(isAvailable: available);
  }

  /// Start listening for speech input
  Future<void> startListening() async {
    // Clear any previous error
    state = state.copyWith(error: null, recognizedText: '');

    await _service.startListening(
      onResult: (result) {
        state = state.copyWith(
          recognizedText: result.recognizedWords,
          isListening: !result.finalResult,
        );
      },
    );

    state = state.copyWith(isListening: true);
  }

  /// Stop listening for speech input
  Future<void> stopListening() async {
    await _service.stopListening();
    state = state.copyWith(isListening: false);
  }

  /// Toggle listening state
  Future<void> toggleListening() async {
    if (state.isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  /// Clear the recognized text
  void clearText() {
    state = state.copyWith(recognizedText: '');
  }

  /// Set an error state
  void setError(String message) {
    state = state.copyWith(error: message, isListening: false);
  }
}

/// Provider for speech recognition state
final speechProvider = StateNotifierProvider<SpeechNotifier, SpeechState>((ref) {
  final service = ref.watch(speechServiceProvider);
  return SpeechNotifier(service);
});

/// Convenience provider for listening state
final isListeningProvider = Provider<bool>((ref) {
  return ref.watch(speechProvider.select((state) => state.isListening));
});

/// Convenience provider for recognized text
final recognizedTextProvider = Provider<String>((ref) {
  return ref.watch(speechProvider.select((state) => state.recognizedText));
});
