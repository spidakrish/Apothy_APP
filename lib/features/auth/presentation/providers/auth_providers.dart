import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

// =============================================================================
// Datasource Providers
// =============================================================================

/// Provider for FlutterSecureStorage instance
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
});

/// Provider for AuthLocalDatasource
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthLocalDatasourceImpl(storage: storage);
});

/// Provider for AuthRemoteDatasource
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  // Set useMock to true until backend endpoints are ready
  return AuthRemoteDatasourceImpl(useMock: true);
});

// =============================================================================
// Repository Provider
// =============================================================================

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localDatasource = ref.watch(authLocalDatasourceProvider);
  final remoteDatasource = ref.watch(authRemoteDatasourceProvider);
  return AuthRepositoryImpl(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
    // Set useMock to true until OAuth is properly configured
    // (Apple Developer account, Google Cloud Console, etc.)
    useMock: true,
  );
});

// =============================================================================
// Auth State
// =============================================================================

/// Represents the current authentication status
enum AuthStatus {
  /// Initial state, checking stored credentials
  initial,

  /// User is authenticated
  authenticated,

  /// User is not authenticated
  unauthenticated,

  /// User needs to complete onboarding
  needsOnboarding,
}

/// Complete authentication state
class AuthenticationState {
  const AuthenticationState({
    required this.status,
    this.user,
    this.failure,
  });

  /// Initial state while checking auth
  factory AuthenticationState.initial() => const AuthenticationState(
    status: AuthStatus.initial,
  );

  /// Authenticated state with user
  factory AuthenticationState.authenticated(User user) => AuthenticationState(
    status: AuthStatus.authenticated,
    user: user,
  );

  /// Unauthenticated state
  factory AuthenticationState.unauthenticated() => const AuthenticationState(
    status: AuthStatus.unauthenticated,
  );

  /// Needs onboarding
  factory AuthenticationState.needsOnboarding() => const AuthenticationState(
    status: AuthStatus.needsOnboarding,
  );

  /// Error state with failure
  factory AuthenticationState.error(Failure failure) => AuthenticationState(
    status: AuthStatus.unauthenticated,
    failure: failure,
  );

  final AuthStatus status;
  final User? user;
  final Failure? failure;

  /// Whether the user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Whether we're still checking auth status
  bool get isLoading => status == AuthStatus.initial;

  /// Whether there's an error
  bool get hasError => failure != null;

  AuthenticationState copyWith({
    AuthStatus? status,
    User? user,
    Failure? failure,
  }) {
    return AuthenticationState(
      status: status ?? this.status,
      user: user ?? this.user,
      failure: failure,
    );
  }
}

// =============================================================================
// Auth Notifier
// =============================================================================

/// Notifier for managing authentication state
class AuthNotifier extends AsyncNotifier<AuthenticationState> {
  late AuthRepository _repository;

  @override
  Future<AuthenticationState> build() async {
    _repository = ref.watch(authRepositoryProvider);
    return _checkAuthStatus();
  }

  /// Checks current authentication status
  Future<AuthenticationState> _checkAuthStatus() async {
    // First check if user has completed onboarding
    debugPrint('AuthNotifier: checking onboarding status...');
    final hasOnboarded = await _repository.hasCompletedOnboarding();
    debugPrint('AuthNotifier: hasOnboarded = $hasOnboarded');

    if (!hasOnboarded) {
      debugPrint('AuthNotifier: returning needsOnboarding');
      return AuthenticationState.needsOnboarding();
    }

    // Check for existing session
    debugPrint('AuthNotifier: checking for existing session...');
    final result = await _repository.getCurrentUser();

    return result.fold(
      (failure) {
        debugPrint('AuthNotifier: error getting user: ${failure.message}');
        return AuthenticationState.error(failure);
      },
      (authState) {
        if (authState == null) {
          debugPrint('AuthNotifier: no user found, returning unauthenticated');
          return AuthenticationState.unauthenticated();
        }
        debugPrint('AuthNotifier: user found, returning authenticated');
        return AuthenticationState.authenticated(authState.user);
      },
    );
  }

  /// Signs in with Apple
  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();

    final result = await _repository.signInWithApple();

    state = AsyncValue.data(
      result.fold(
        (failure) => AuthenticationState.error(failure),
        (authState) => AuthenticationState.authenticated(authState.user),
      ),
    );
  }

  /// Signs in with Google
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    final result = await _repository.signInWithGoogle();

    state = AsyncValue.data(
      result.fold(
        (failure) => AuthenticationState.error(failure),
        (authState) => AuthenticationState.authenticated(authState.user),
      ),
    );
  }

  /// Signs in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.signInWithEmail(
      email: email,
      password: password,
    );

    state = AsyncValue.data(
      result.fold(
        (failure) => AuthenticationState.error(failure),
        (authState) => AuthenticationState.authenticated(authState.user),
      ),
    );
  }

  /// Signs up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );

    state = AsyncValue.data(
      result.fold(
        (failure) => AuthenticationState.error(failure),
        (authState) => AuthenticationState.authenticated(authState.user),
      ),
    );
  }

  /// Signs out the current user
  Future<void> signOut() async {
    state = const AsyncValue.loading();

    final result = await _repository.signOut();

    state = AsyncValue.data(
      result.fold(
        (failure) => AuthenticationState.error(failure),
        (_) => AuthenticationState.unauthenticated(),
      ),
    );
  }

  /// Completes onboarding and checks auth status
  Future<void> completeOnboarding() async {
    await _repository.completeOnboarding();

    // After onboarding, check if user is authenticated
    state = const AsyncValue.loading();

    final result = await _repository.getCurrentUser();

    state = AsyncValue.data(
      result.fold(
        (failure) => AuthenticationState.unauthenticated(),
        (authState) {
          if (authState == null) {
            return AuthenticationState.unauthenticated();
          }
          return AuthenticationState.authenticated(authState.user);
        },
      ),
    );
  }

  /// Updates user profile (display name, avatar)
  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.isAuthenticated) {
      return false;
    }

    final result = await _repository.updateProfile(
      displayName: displayName,
      photoUrl: photoUrl,
    );

    return result.fold(
      (failure) {
        // Update state with error but keep user authenticated
        state = AsyncValue.data(
          currentState.copyWith(failure: failure),
        );
        return false;
      },
      (updatedUser) {
        // Update state with new user data
        state = AsyncValue.data(
          AuthenticationState.authenticated(updatedUser),
        );
        return true;
      },
    );
  }

  /// Clears any error state
  void clearError() {
    final currentState = state.valueOrNull;
    if (currentState != null && currentState.hasError) {
      state = AsyncValue.data(
        currentState.copyWith(failure: null),
      );
    }
  }
}

// =============================================================================
// Main Auth Provider
// =============================================================================

/// Main provider for authentication state
///
/// Usage:
/// ```dart
/// final authState = ref.watch(authProvider);
/// authState.when(
///   data: (state) => ...,
///   loading: () => ...,
///   error: (e, st) => ...,
/// );
/// ```
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthenticationState>(
  AuthNotifier.new,
);

// =============================================================================
// Convenience Providers
// =============================================================================

/// Provider that returns just the auth status
final authStatusProvider = Provider<AuthStatus>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (state) => state.status,
    orElse: () => AuthStatus.initial,
  );
});

/// Provider that returns the current user (if authenticated)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (state) => state.user,
    orElse: () => null,
  );
});

/// Provider that returns whether user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final status = ref.watch(authStatusProvider);
  return status == AuthStatus.authenticated;
});

/// Provider that returns whether we're still checking auth
final isAuthLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isLoading ||
      authState.maybeWhen(
        data: (state) => state.status == AuthStatus.initial,
        orElse: () => false,
      );
});

/// Provider to check if user has completed mirror introduction
final mirrorIntroStatusProvider = FutureProvider<bool>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.hasCompletedMirrorIntro();
});
