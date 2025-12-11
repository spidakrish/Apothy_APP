import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_tokens.dart';
import '../entities/user.dart';

/// Authentication state returned from auth operations
class AuthState {
  const AuthState({
    required this.user,
    required this.tokens,
  });

  final User user;
  final AuthTokens tokens;
}

/// Abstract repository interface for authentication operations
///
/// This interface is defined in the domain layer and implemented
/// in the data layer, following clean architecture principles.
abstract class AuthRepository {
  /// Signs in user with Apple credentials
  ///
  /// Returns [AuthState] on success or [Failure] on error
  Future<Either<Failure, AuthState>> signInWithApple();

  /// Signs in user with Google credentials
  ///
  /// Returns [AuthState] on success or [Failure] on error
  Future<Either<Failure, AuthState>> signInWithGoogle();

  /// Signs in user with email and password
  ///
  /// Returns [AuthState] on success or [Failure] on error
  Future<Either<Failure, AuthState>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Registers a new user with email and password
  ///
  /// Returns [AuthState] on success or [Failure] on error
  Future<Either<Failure, AuthState>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Signs out the current user
  ///
  /// Returns [Unit] on success or [Failure] on error
  Future<Either<Failure, Unit>> signOut();

  /// Checks if user is currently authenticated
  ///
  /// Returns [AuthState] if authenticated, null otherwise
  Future<Either<Failure, AuthState?>> getCurrentUser();

  /// Refreshes the access token if expired
  ///
  /// Returns [AuthTokens] on success or [Failure] on error
  Future<Either<Failure, AuthTokens>> refreshTokenIfNeeded();

  /// Gets current authentication tokens
  ///
  /// Returns [AuthTokens] if available, null otherwise
  Future<Either<Failure, AuthTokens?>> getTokens();

  /// Checks if user has completed onboarding
  Future<bool> hasCompletedOnboarding();

  /// Marks onboarding as completed
  Future<void> completeOnboarding();

  /// Checks if user has completed mirror introduction
  Future<bool> hasCompletedMirrorIntro();

  /// Marks mirror introduction as completed
  Future<void> completeMirrorIntro();

  /// Updates user profile (display name, avatar)
  Future<Either<Failure, User>> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Clears onboarding status (for deep reset)
  Future<void> clearOnboarding();

  /// Clears all local auth data including onboarding (for deep reset)
  Future<Either<Failure, Unit>> clearAllLocalData();

  /// Deletes user account permanently (GDPR compliance)
  /// This will:
  /// - Delete cloud account and all cloud data
  /// - Clear all local data including onboarding
  Future<Either<Failure, Unit>> deleteAccount();
}
