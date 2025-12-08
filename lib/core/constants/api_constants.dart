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
  // Timeouts
  // ============================================================================

  /// Default connection timeout in seconds
  static const int connectionTimeout = 30;

  /// Default receive timeout in seconds
  static const int receiveTimeout = 60;

  /// Streaming timeout in seconds (for chat responses)
  static const int streamingTimeout = 120;
}
