/// AI Configuration for Apothy
///
/// This file contains all AI-related configuration settings.
/// Developer: Replace placeholder values with actual API credentials.
///
/// IMPORTANT: Never commit actual API keys to version control!
/// Use environment variables or secure storage in production.
class AIConfig {
  AIConfig._();

  // ============================================================================
  // API Configuration
  // ============================================================================

  /// Whether to use mock responses instead of real API calls
  /// Set to false when backend is ready
  ///
  /// DEVELOPER: Change this to false when connecting to real AI backend
  static const bool useMockResponses = true;

  /// AI API Base URL
  /// This can be different from the main API if using a separate AI service
  ///
  /// DEVELOPER: Replace with your AI service base URL
  /// Examples:
  /// - OpenAI: 'https://api.openai.com/v1'
  /// - Claude: 'https://api.anthropic.com/v1'
  /// - Custom: 'https://your-ai-service.com/api'
  /// - Apothy Backend: Use ApiConstants.baseUrl
  static const String aiBaseUrl = 'PLACEHOLDER_AI_BASE_URL';

  /// AI API Key
  ///
  /// DEVELOPER: Replace with your actual API key
  /// WARNING: Do NOT hardcode API keys in production!
  /// Use flutter_secure_storage or environment variables instead.
  ///
  /// For production, load from:
  /// - flutter_secure_storage
  /// - Environment variables via --dart-define
  /// - Backend-provided keys
  static const String aiApiKey = 'PLACEHOLDER_AI_API_KEY';

  // ============================================================================
  // Model Configuration
  // ============================================================================

  /// AI Model to use for chat completions
  ///
  /// DEVELOPER: Set your preferred model
  /// Examples:
  /// - OpenAI: 'gpt-4', 'gpt-4-turbo', 'gpt-3.5-turbo'
  /// - Claude: 'claude-3-opus', 'claude-3-sonnet', 'claude-3-haiku'
  /// - Custom: Your model identifier
  static const String defaultModel = 'PLACEHOLDER_MODEL_ID';

  /// Maximum tokens in AI response
  ///
  /// DEVELOPER: Adjust based on your pricing/usage needs
  /// Higher = more detailed responses but more expensive
  static const int maxResponseTokens = 1024;

  /// Maximum conversation history to send (number of messages)
  /// Limits context window usage and costs
  ///
  /// DEVELOPER: Adjust based on your context window limits
  static const int maxHistoryMessages = 20;

  /// Temperature for AI responses (0.0 - 2.0)
  /// Lower = more focused/deterministic
  /// Higher = more creative/random
  ///
  /// DEVELOPER: Adjust for desired response style
  static const double defaultTemperature = 0.7;

  // ============================================================================
  // Response Style Mapping
  // ============================================================================

  /// Maps user preference styles to temperature values
  /// Used with settings preferences
  static const Map<String, double> styleTemperatures = {
    'creative': 1.0,   // More creative responses
    'balanced': 0.7,   // Default balanced responses
    'precise': 0.3,    // More precise/focused responses
  };

  // ============================================================================
  // Timeout Configuration
  // ============================================================================

  /// Connection timeout for AI requests (seconds)
  static const int connectionTimeoutSeconds = 30;

  /// Response timeout for AI requests (seconds)
  /// AI responses can take longer, so this is higher than regular API calls
  static const int responseTimeoutSeconds = 90;

  /// Streaming response timeout (seconds)
  /// For real-time streaming responses
  static const int streamingTimeoutSeconds = 120;

  // ============================================================================
  // Retry Configuration
  // ============================================================================

  /// Number of retry attempts on failure
  static const int maxRetries = 3;

  /// Delay between retries (milliseconds)
  static const int retryDelayMs = 1000;

  /// Exponential backoff multiplier for retries
  static const double retryBackoffMultiplier = 2.0;

  // ============================================================================
  // System Prompt
  // ============================================================================

  /// System prompt that defines the AI assistant's personality and behavior
  ///
  /// DEVELOPER: Customize this for your app's use case
  static const String systemPrompt = '''
You are Apothy, a friendly and supportive AI companion.

Your role is to:
- Be warm, empathetic, and understanding
- Provide helpful and thoughtful responses
- Support users with their questions and concerns
- Maintain a positive and encouraging tone
- Be concise but thorough in your responses

Remember to:
- Never provide medical, legal, or financial advice
- Encourage users to seek professional help when appropriate
- Respect user privacy and boundaries
- Stay within your knowledge limitations
''';

  // ============================================================================
  // Request Headers
  // ============================================================================

  /// Additional headers for AI API requests
  ///
  /// DEVELOPER: Add any provider-specific headers here
  static Map<String, String> get additionalHeaders => {
    // OpenAI format:
    // 'OpenAI-Organization': 'your-org-id',

    // Anthropic format:
    // 'anthropic-version': '2024-01-01',

    // Custom headers:
    // 'X-Custom-Header': 'value',
  };

  // ============================================================================
  // Feature Flags
  // ============================================================================

  /// Whether streaming responses are enabled
  /// Set to true if your AI backend supports SSE/streaming
  static const bool enableStreaming = false;

  /// Whether to log AI requests/responses for debugging
  /// Set to false in production!
  static const bool enableDebugLogging = true;

  /// Whether to send conversation history with each request
  /// Some backends manage context internally
  static const bool sendConversationHistory = true;
}
