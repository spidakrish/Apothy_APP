import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Service for speech-to-text functionality
/// Wraps the speech_to_text plugin with a clean interface
class SpeechService {
  SpeechService() : _speechToText = SpeechToText();

  final SpeechToText _speechToText;
  bool _isInitialized = false;

  /// Whether speech recognition is available on this device
  bool get isAvailable => _isInitialized;

  /// Whether the service is currently listening
  bool get isListening => _speechToText.isListening;

  /// Initialize the speech recognition service
  /// Returns true if speech recognition is available
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    _isInitialized = await _speechToText.initialize(
      onError: (error) {
        // Error handling is done via the provider
      },
      onStatus: (status) {
        // Status handling is done via the provider
      },
    );

    return _isInitialized;
  }

  /// Start listening for speech
  /// [onResult] is called with each recognition result (including partial)
  /// [localeId] is the language locale (e.g., 'en_US')
  Future<void> startListening({
    required void Function(SpeechRecognitionResult result) onResult,
    String? localeId,
  }) async {
    if (!_isInitialized) {
      final available = await initialize();
      if (!available) return;
    }

    await _speechToText.listen(
      onResult: onResult,
      localeId: localeId,
      listenOptions: stt.SpeechListenOptions(
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  /// Stop listening for speech
  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  /// Cancel the current listening session
  Future<void> cancelListening() async {
    await _speechToText.cancel();
  }

  /// Get available locales for speech recognition
  Future<List<LocaleName>> getLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _speechToText.locales();
  }

  /// Dispose of resources
  void dispose() {
    _speechToText.cancel();
  }
}
