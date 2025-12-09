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
