/// API endpoint constants for Apothy backend
class ApiConstants {
  ApiConstants._();

  /// Production API base URL
  static const String productionBaseUrl =
      'https://xnfhbfcbpptm6bqdvs5gi6gimu0xiguq.lambda-url.ap-southeast-2.on.aws';

  /// Staging API base URL
  static const String stagingBaseUrl = 'https://api-staging.apothy.ai';

  /// Local development API base URL
  static const String localBaseUrl = 'http://localhost:8000';

  /// Current environment base URL (change for different environments)
  static const String baseUrl = productionBaseUrl;

  // ============================================================================
  // Chat Endpoints
  // ============================================================================

  /// Get all user chats
  static const String chats = '/chats';

  /// Create new chat / Get chat messages / Delete chat
  /// Use: $chats/$chatId
  static String chat(String chatId) => '/chats/$chatId';

  /// Proactive reachout
  static String proactiveReachout(String chatId) => '/chats/proactive/$chatId';

  // ============================================================================
  // User Endpoints
  // ============================================================================

  /// Get user profile and subscription status
  static const String user = '/user';

  // ============================================================================
  // Gamification Endpoints
  // ============================================================================

  /// Get user XP points
  static const String gamificationPoints = '/gamification/points';

  /// Get all achievements
  static const String gamificationAchievements = '/gamification/achievements';

  /// Get earned achievements
  static const String gamificationEarnedAchievements =
      '/gamification/earned_achievements';

  // ============================================================================
  // Subscription Endpoints
  // ============================================================================

  /// Get subscription details
  static const String subscription = '/subscription';

  /// Get payment history
  static const String payments = '/payments';

  // ============================================================================
  // AI Chat Endpoints
  // ============================================================================

  /// Send message to AI and get response
  /// POST: Send user message with conversation history
  /// Expected request body:
  /// {
  ///   "conversation_id": "string",
  ///   "message": "string",
  ///   "history": [{"role": "user|assistant", "content": "string"}],
  ///   "style": "balanced|creative|precise" (optional)
  /// }
  /// Expected response:
  /// {
  ///   "response": "string",
  ///   "conversation_id": "string"
  /// }
  static const String aiChat = '/ai/chat';

  /// Stream AI response (for real-time typing effect)
  /// GET with SSE (Server-Sent Events)
  static const String aiChatStream = '/ai/chat/stream';

  /// Get AI conversation context/summary
  static String aiConversationContext(String conversationId) =>
      '/ai/conversations/$conversationId/context';

  // ============================================================================
  // Timeouts
  // ============================================================================

  /// Default connection timeout in seconds
  static const int connectionTimeout = 30;

  /// Default receive timeout in seconds
  static const int receiveTimeout = 60;

  /// Streaming timeout in seconds (for chat responses)
  static const int streamingTimeout = 120;

  /// AI response timeout in seconds (longer for complex responses)
  static const int aiResponseTimeout = 90;
}
