import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
///
/// Failures are used with fpdart's Either type to represent
/// error states in a functional way without using exceptions.
abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    this.code,
  });

  /// Human-readable error message
  final String message;

  /// Optional error code for programmatic handling
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

/// Failure related to authentication operations
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });

  /// Invalid credentials provided
  factory AuthFailure.invalidCredentials() => const AuthFailure(
    message: 'Invalid email or password',
    code: 'invalid_credentials',
  );

  /// User account not found
  factory AuthFailure.userNotFound() => const AuthFailure(
    message: 'No account found with this email',
    code: 'user_not_found',
  );

  /// Account already exists
  factory AuthFailure.accountExists() => const AuthFailure(
    message: 'An account with this email already exists',
    code: 'account_exists',
  );

  /// Token expired
  factory AuthFailure.tokenExpired() => const AuthFailure(
    message: 'Your session has expired. Please sign in again.',
    code: 'token_expired',
  );

  /// Token refresh failed
  factory AuthFailure.refreshFailed() => const AuthFailure(
    message: 'Unable to refresh your session. Please sign in again.',
    code: 'refresh_failed',
  );

  /// Apple Sign-In failed
  factory AuthFailure.appleSignInFailed([String? details]) => AuthFailure(
    message: details ?? 'Apple Sign-In failed. Please try again.',
    code: 'apple_sign_in_failed',
  );

  /// Google Sign-In failed
  factory AuthFailure.googleSignInFailed([String? details]) => AuthFailure(
    message: details ?? 'Google Sign-In failed. Please try again.',
    code: 'google_sign_in_failed',
  );

  /// User cancelled sign-in
  factory AuthFailure.cancelled() => const AuthFailure(
    message: 'Sign-in was cancelled',
    code: 'cancelled',
  );

  /// Generic auth failure
  factory AuthFailure.unknown([String? message]) => AuthFailure(
    message: message ?? 'An authentication error occurred',
    code: 'unknown',
  );
}

/// Failure related to network operations
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });

  /// No internet connection
  factory NetworkFailure.noConnection() => const NetworkFailure(
    message: 'No internet connection. Please check your network.',
    code: 'no_connection',
  );

  /// Connection timeout
  factory NetworkFailure.timeout() => const NetworkFailure(
    message: 'Connection timed out. Please try again.',
    code: 'timeout',
  );

  /// Server error (5xx)
  factory NetworkFailure.serverError() => const NetworkFailure(
    message: 'Server error. Please try again later.',
    code: 'server_error',
  );

  /// Service unavailable
  factory NetworkFailure.serviceUnavailable() => const NetworkFailure(
    message: 'Service is currently unavailable. Please try again later.',
    code: 'service_unavailable',
  );
}

/// Failure related to local storage operations
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
  });

  /// Failed to read from storage
  factory StorageFailure.readFailed() => const StorageFailure(
    message: 'Failed to read data from storage',
    code: 'read_failed',
  );

  /// Failed to write to storage
  factory StorageFailure.writeFailed() => const StorageFailure(
    message: 'Failed to save data to storage',
    code: 'write_failed',
  );

  /// Data corruption
  factory StorageFailure.corrupted() => const StorageFailure(
    message: 'Stored data is corrupted',
    code: 'corrupted',
  );

  /// Failed to delete from storage
  factory StorageFailure.deleteFailed() => const StorageFailure(
    message: 'Failed to delete data from storage',
    code: 'delete_failed',
  );
}

/// Failure related to validation
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    this.field,
  });

  /// The field that failed validation (if applicable)
  final String? field;

  /// Invalid email format
  factory ValidationFailure.invalidEmail() => const ValidationFailure(
    message: 'Please enter a valid email address',
    code: 'invalid_email',
    field: 'email',
  );

  /// Password too weak
  factory ValidationFailure.weakPassword() => const ValidationFailure(
    message: 'Password must be at least 8 characters with a number and symbol',
    code: 'weak_password',
    field: 'password',
  );

  /// Passwords don't match
  factory ValidationFailure.passwordMismatch() => const ValidationFailure(
    message: 'Passwords do not match',
    code: 'password_mismatch',
    field: 'confirmPassword',
  );

  /// Required field is empty
  factory ValidationFailure.required(String fieldName) => ValidationFailure(
    message: '$fieldName is required',
    code: 'required',
    field: fieldName,
  );

  @override
  List<Object?> get props => [...super.props, field];
}

/// Failure related to chat operations
class ChatFailure extends Failure {
  const ChatFailure({
    required super.message,
    super.code,
  });

  /// Failed to save message or conversation
  factory ChatFailure.saveFailed([String? details]) => ChatFailure(
    message: details ?? 'Failed to save chat data',
    code: 'save_failed',
  );

  /// Failed to load messages or conversations
  factory ChatFailure.loadFailed([String? details]) => ChatFailure(
    message: details ?? 'Failed to load chat data',
    code: 'load_failed',
  );

  /// Failed to delete message or conversation
  factory ChatFailure.deleteFailed([String? details]) => ChatFailure(
    message: details ?? 'Failed to delete chat data',
    code: 'delete_failed',
  );

  /// Failed to create conversation
  factory ChatFailure.createConversationFailed([String? details]) => ChatFailure(
    message: details ?? 'Failed to create conversation',
    code: 'create_conversation_failed',
  );

  /// Conversation not found
  factory ChatFailure.conversationNotFound() => const ChatFailure(
    message: 'Conversation not found',
    code: 'conversation_not_found',
  );

  /// Message not found
  factory ChatFailure.messageNotFound() => const ChatFailure(
    message: 'Message not found',
    code: 'message_not_found',
  );

  /// Storage not initialized
  factory ChatFailure.notInitialized() => const ChatFailure(
    message: 'Chat storage not initialized',
    code: 'not_initialized',
  );

  /// Generic chat failure
  factory ChatFailure.unknown([String? message]) => ChatFailure(
    message: message ?? 'An error occurred in chat',
    code: 'unknown',
  );
}

/// Failure related to AI chat operations
class AIFailure extends Failure {
  const AIFailure({
    required super.message,
    super.code,
  });

  /// AI response timed out
  factory AIFailure.timeout() => const AIFailure(
    message: 'AI response timed out. Please try again.',
    code: 'ai_timeout',
  );

  /// Rate limited by AI service
  factory AIFailure.rateLimited() => const AIFailure(
    message: 'Too many requests. Please wait a moment and try again.',
    code: 'ai_rate_limited',
  );

  /// Invalid response from AI service
  factory AIFailure.invalidResponse() => const AIFailure(
    message: 'Received an invalid response from AI. Please try again.',
    code: 'ai_invalid_response',
  );

  /// AI service unavailable
  factory AIFailure.serviceUnavailable() => const AIFailure(
    message: 'AI service is currently unavailable. Please try again later.',
    code: 'ai_service_unavailable',
  );

  /// AI API key invalid or missing
  factory AIFailure.authenticationFailed() => const AIFailure(
    message: 'AI authentication failed. Please check your configuration.',
    code: 'ai_auth_failed',
  );

  /// Content moderation blocked the response
  factory AIFailure.contentBlocked() => const AIFailure(
    message: 'This message could not be processed. Please try rephrasing.',
    code: 'ai_content_blocked',
  );

  /// Context too long for AI to process
  factory AIFailure.contextTooLong() => const AIFailure(
    message: 'Conversation is too long. Please start a new conversation.',
    code: 'ai_context_too_long',
  );

  /// Generic AI failure
  factory AIFailure.unknown([String? message]) => AIFailure(
    message: message ?? 'An error occurred while getting AI response',
    code: 'ai_unknown',
  );
}

/// Failure related to dashboard operations
class DashboardFailure extends Failure {
  const DashboardFailure({
    required super.message,
    super.code,
  });

  /// Failed to load dashboard data
  factory DashboardFailure.loadFailed([String? details]) => DashboardFailure(
    message: details ?? 'Failed to load dashboard data',
    code: 'load_failed',
  );

  /// Failed to save dashboard data
  factory DashboardFailure.saveFailed([String? details]) => DashboardFailure(
    message: details ?? 'Failed to save dashboard data',
    code: 'save_failed',
  );

  /// Failed to award XP
  factory DashboardFailure.xpAwardFailed([String? details]) => DashboardFailure(
    message: details ?? 'Failed to award XP',
    code: 'xp_award_failed',
  );

  /// Failed to update streak
  factory DashboardFailure.streakUpdateFailed([String? details]) => DashboardFailure(
    message: details ?? 'Failed to update streak',
    code: 'streak_update_failed',
  );

  /// Achievement not found
  factory DashboardFailure.achievementNotFound() => const DashboardFailure(
    message: 'Achievement not found',
    code: 'achievement_not_found',
  );

  /// Storage not initialized
  factory DashboardFailure.notInitialized() => const DashboardFailure(
    message: 'Dashboard storage not initialized',
    code: 'not_initialized',
  );

  /// Generic dashboard failure
  factory DashboardFailure.unknown([String? message]) => DashboardFailure(
    message: message ?? 'An error occurred in dashboard',
    code: 'unknown',
  );
}

/// Failure related to subscription and in-app purchase operations
class SubscriptionFailure extends Failure {
  const SubscriptionFailure({
    required super.message,
    super.code,
  });

  /// Failed to load subscription status
  factory SubscriptionFailure.loadFailed([String? details]) => SubscriptionFailure(
    message: details ?? 'Failed to load subscription status',
    code: 'load_failed',
  );

  /// Purchase was cancelled by user
  factory SubscriptionFailure.purchaseCancelled() => const SubscriptionFailure(
    message: 'Purchase was cancelled',
    code: 'purchase_cancelled',
  );

  /// Purchase failed
  factory SubscriptionFailure.purchaseFailed([String? details]) => SubscriptionFailure(
    message: details ?? 'Purchase failed. Please try again.',
    code: 'purchase_failed',
  );

  /// User already owns this subscription
  factory SubscriptionFailure.alreadyOwned() => const SubscriptionFailure(
    message: 'You already have this subscription',
    code: 'already_owned',
  );

  /// Payment pending
  factory SubscriptionFailure.paymentPending() => const SubscriptionFailure(
    message: 'Payment is pending. Please wait for confirmation.',
    code: 'payment_pending',
  );

  /// Failed to restore purchases
  factory SubscriptionFailure.restoreFailed([String? details]) => SubscriptionFailure(
    message: details ?? 'Failed to restore purchases',
    code: 'restore_failed',
  );

  /// No purchases to restore
  factory SubscriptionFailure.noPurchases() => const SubscriptionFailure(
    message: 'No previous purchases found',
    code: 'no_purchases',
  );

  /// RevenueCat not configured
  factory SubscriptionFailure.notConfigured() => const SubscriptionFailure(
    message: 'Subscription service is not configured',
    code: 'not_configured',
  );

  /// Storage not initialized
  factory SubscriptionFailure.notInitialized() => const SubscriptionFailure(
    message: 'Subscription storage not initialized',
    code: 'not_initialized',
  );

  /// Generic subscription failure
  factory SubscriptionFailure.unknown([String? message]) => SubscriptionFailure(
    message: message ?? 'An error occurred with subscription',
    code: 'unknown',
  );
}

/// Failure related to cache operations
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });

  /// Failed to read from cache
  factory CacheFailure.readFailed([String? details]) => CacheFailure(
    message: details ?? 'Failed to read from cache',
    code: 'cache_read_failed',
  );

  /// Failed to write to cache
  factory CacheFailure.writeFailed([String? details]) => CacheFailure(
    message: details ?? 'Failed to write to cache',
    code: 'cache_write_failed',
  );

  /// Cache is invalid or expired
  factory CacheFailure.invalid() => const CacheFailure(
    message: 'Cache is invalid or expired',
    code: 'cache_invalid',
  );

  /// Generic cache failure
  factory CacheFailure.unknown([String? message]) => CacheFailure(
    message: message ?? 'Cache error occurred',
    code: 'cache_unknown',
  );
}
