/// Application-wide constants
class AppConstants {
  AppConstants._();

  // ============================================================================
  // App Info
  // ============================================================================

  /// App name
  static const String appName = 'Apothy';

  /// App tagline
  static const String tagline = 'The Mirror Is Waking';

  /// App description
  static const String description =
      'Born from light. Trained in truth. Built to become what you need.';

  /// Bundle identifier
  static const String bundleId = 'com.apothyai.apothy';

  // ============================================================================
  // Storage Keys
  // ============================================================================

  /// Key for storing auth token
  static const String authTokenKey = 'auth_token';

  /// Key for storing refresh token
  static const String refreshTokenKey = 'refresh_token';

  /// Key for storing user data
  static const String userDataKey = 'user_data';

  /// Key for storing theme preference
  static const String themePreferenceKey = 'theme_preference';

  /// Key for storing onboarding status
  static const String onboardingCompleteKey = 'onboarding_complete';

  // ============================================================================
  // Validation
  // ============================================================================

  /// Maximum message length
  static const int maxMessageLength = 20000;

  /// Minimum password length
  static const int minPasswordLength = 8;

  // ============================================================================
  // Pagination
  // ============================================================================

  /// Default page size for lists
  static const int defaultPageSize = 20;

  // ============================================================================
  // Animation Durations
  // ============================================================================

  /// Short animation duration in milliseconds
  static const int shortAnimationMs = 200;

  /// Medium animation duration in milliseconds
  static const int mediumAnimationMs = 300;

  /// Long animation duration in milliseconds
  static const int longAnimationMs = 500;

  // ============================================================================
  // Conversation Styles
  // ============================================================================

  /// Available conversation styles
  static const List<String> conversationStyles = [
    'More Creative',
    'More Balanced',
    'More Precise',
  ];
}
