import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

/// Implementation of [AuthRepository]
///
/// Coordinates between local and remote datasources to handle
/// authentication operations with proper error handling using fpdart Either.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthLocalDatasource localDatasource,
    required AuthRemoteDatasource remoteDatasource,
    GoogleSignIn? googleSignIn,
    this.useMock = false,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _googleSignIn = googleSignIn ?? GoogleSignIn(
          scopes: ['email', 'profile'],
        );

  final AuthLocalDatasource _localDatasource;
  final AuthRemoteDatasource _remoteDatasource;
  final GoogleSignIn _googleSignIn;

  /// When true, bypasses native SDK calls (Apple/Google) for development.
  /// Set to true until OAuth is properly configured.
  final bool useMock;

  @override
  Future<Either<Failure, AuthState>> signInWithApple() async {
    try {
      // In mock mode, bypass native SDK and use mock data
      if (useMock) {
        final result = await _remoteDatasource.signInWithApple(
          identityToken: 'mock_identity_token',
          authorizationCode: 'mock_authorization_code',
          email: 'apple_user@apothy.ai',
          fullName: 'Apple User',
        );
        await _saveAuthResult(result);
        return right(AuthState(
          user: result.user.toEntity(),
          tokens: result.tokens.toEntity(),
        ));
      }

      // Request Apple Sign-In credentials
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Extract identity token and authorization code
      final identityToken = credential.identityToken;
      final authorizationCode = credential.authorizationCode;

      if (identityToken == null) {
        return left(AuthFailure.appleSignInFailed('No identity token received'));
      }

      // Build full name from components
      String? fullName;
      if (credential.givenName != null || credential.familyName != null) {
        fullName = [credential.givenName, credential.familyName]
            .where((n) => n != null && n.isNotEmpty)
            .join(' ');
        if (fullName.isEmpty) fullName = null;
      }

      // Authenticate with backend
      final result = await _remoteDatasource.signInWithApple(
        identityToken: identityToken,
        authorizationCode: authorizationCode,
        email: credential.email,
        fullName: fullName,
      );

      // Save to local storage
      await _saveAuthResult(result);

      return right(AuthState(
        user: result.user.toEntity(),
        tokens: result.tokens.toEntity(),
      ));
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return left(AuthFailure.cancelled());
      }
      return left(AuthFailure.appleSignInFailed(e.message));
    } on AuthException catch (e) {
      return left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return left(AuthFailure.appleSignInFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthState>> signInWithGoogle() async {
    try {
      // In mock mode, bypass native SDK and use mock data
      if (useMock) {
        final result = await _remoteDatasource.signInWithGoogle(
          idToken: 'mock_id_token',
          accessToken: 'mock_access_token',
        );
        await _saveAuthResult(result);
        return right(AuthState(
          user: result.user.toEntity(),
          tokens: result.tokens.toEntity(),
        ));
      }

      // Trigger Google Sign-In flow
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return left(AuthFailure.cancelled());
      }

      // Get authentication details
      final googleAuth = await googleUser.authentication;

      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) {
        return left(AuthFailure.googleSignInFailed('Failed to get tokens'));
      }

      // Authenticate with backend
      final result = await _remoteDatasource.signInWithGoogle(
        idToken: idToken,
        accessToken: accessToken,
      );

      // Save to local storage
      await _saveAuthResult(result);

      return right(AuthState(
        user: result.user.toEntity(),
        tokens: result.tokens.toEntity(),
      ));
    } on AuthException catch (e) {
      return left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      // Check if user cancelled
      if (e.toString().contains('canceled') ||
          e.toString().contains('cancelled')) {
        return left(AuthFailure.cancelled());
      }
      return left(AuthFailure.googleSignInFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthState>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty) {
        return left(ValidationFailure.required('Email'));
      }
      if (password.isEmpty) {
        return left(ValidationFailure.required('Password'));
      }

      // Authenticate with backend
      final result = await _remoteDatasource.signInWithEmail(
        email: email,
        password: password,
      );

      // Save to local storage
      await _saveAuthResult(result);

      return right(AuthState(
        user: result.user.toEntity(),
        tokens: result.tokens.toEntity(),
      ));
    } on AuthException catch (e) {
      if (e.code == 'unauthorized') {
        return left(AuthFailure.invalidCredentials());
      }
      return left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return left(AuthFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthState>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty) {
        return left(ValidationFailure.required('Email'));
      }
      if (!_isValidEmail(email)) {
        return left(ValidationFailure.invalidEmail());
      }
      if (password.isEmpty) {
        return left(ValidationFailure.required('Password'));
      }
      if (!_isValidPassword(password)) {
        return left(ValidationFailure.weakPassword());
      }

      // Register with backend
      final result = await _remoteDatasource.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Save to local storage
      await _saveAuthResult(result);

      return right(AuthState(
        user: result.user.toEntity(),
        tokens: result.tokens.toEntity(),
      ));
    } on AuthException catch (e) {
      if (e.code == 'conflict') {
        return left(AuthFailure.accountExists());
      }
      return left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return left(AuthFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      // Get current access token for backend logout
      final tokens = await _localDatasource.getTokens();

      if (tokens != null && tokens.accessToken.isNotEmpty) {
        // Notify backend (don't fail if this fails)
        await _remoteDatasource.signOut(tokens.accessToken);
      }

      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Clear local storage
      await _localDatasource.clearAll();

      return right(unit);
    } catch (e) {
      // Even if remote logout fails, clear local data
      try {
        await _localDatasource.clearAll();
      } catch (_) {}

      // Return success since local state is cleared
      return right(unit);
    }
  }

  @override
  Future<Either<Failure, AuthState?>> getCurrentUser() async {
    try {
      // Check local storage for existing session
      final tokens = await _localDatasource.getTokens();
      final user = await _localDatasource.getUser();

      if (tokens == null || user == null) {
        return right(null); // Not authenticated
      }

      // Check if tokens are valid
      if (tokens.isEmpty) {
        return right(null);
      }

      // If token is expired, try to refresh
      if (tokens.isExpired) {
        final refreshResult = await refreshTokenIfNeeded();
        return refreshResult.fold(
          (failure) {
            // Clear storage on refresh failure
            _localDatasource.clearAll();
            return right(null);
          },
          (newTokens) => right(AuthState(
            user: user.toEntity(),
            tokens: newTokens,
          )),
        );
      }

      return right(AuthState(
        user: user.toEntity(),
        tokens: tokens.toEntity(),
      ));
    } catch (e) {
      return left(StorageFailure.readFailed());
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> refreshTokenIfNeeded() async {
    try {
      final tokens = await _localDatasource.getTokens();

      if (tokens == null || tokens.refreshToken.isEmpty) {
        return left(AuthFailure.refreshFailed());
      }

      // Check if token actually needs refresh
      // Add 5 minute buffer before expiry
      final bufferTime = tokens.expiresAt.subtract(const Duration(minutes: 5));
      if (DateTime.now().isBefore(bufferTime)) {
        return right(tokens.toEntity());
      }

      // Refresh the token
      final newTokens = await _remoteDatasource.refreshToken(
        tokens.refreshToken,
      );

      // Save new tokens
      await _localDatasource.saveTokens(newTokens);

      return right(newTokens.toEntity());
    } on AuthException {
      return left(AuthFailure.refreshFailed());
    } catch (_) {
      return left(AuthFailure.refreshFailed());
    }
  }

  @override
  Future<Either<Failure, AuthTokens?>> getTokens() async {
    try {
      final tokens = await _localDatasource.getTokens();
      return right(tokens?.toEntity());
    } catch (e) {
      return left(StorageFailure.readFailed());
    }
  }

  @override
  Future<bool> hasCompletedOnboarding() {
    return _localDatasource.hasCompletedOnboarding();
  }

  @override
  Future<void> completeOnboarding() {
    return _localDatasource.setOnboardingCompleted();
  }

  @override
  Future<void> clearOnboarding() {
    return _localDatasource.clearOnboarding();
  }

  @override
  Future<bool> hasCompletedMirrorIntro() {
    return _localDatasource.hasCompletedMirrorIntro();
  }

  @override
  Future<void> completeMirrorIntro() {
    return _localDatasource.setMirrorIntroCompleted();
  }

  @override
  Future<Either<Failure, Unit>> clearAllLocalData() async {
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Clear all local auth data including onboarding
      await _localDatasource.clearAllIncludingOnboarding();

      return right(unit);
    } catch (e) {
      return left(StorageFailure.deleteFailed());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount() async {
    try {
      // Get current access token for backend deletion
      final tokens = await _localDatasource.getTokens();

      if (tokens != null && tokens.accessToken.isNotEmpty) {
        // Delete account on backend (this also deletes cloud data)
        await _remoteDatasource.deleteAccount(tokens.accessToken);
      }

      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Clear all local data including onboarding
      await _localDatasource.clearAllIncludingOnboarding();

      return right(unit);
    } on AuthException catch (e) {
      return left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      // Even if remote deletion fails, try to clear local data
      try {
        await _localDatasource.clearAllIncludingOnboarding();
      } catch (_) {}
      return left(AuthFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      // Get current access token
      final tokens = await _localDatasource.getTokens();

      if (tokens == null || tokens.isEmpty) {
        return left(const AuthFailure(
          message: 'Not authenticated',
          code: 'not_authenticated',
        ));
      }

      // Update on backend
      final updatedUser = await _remoteDatasource.updateProfile(
        accessToken: tokens.accessToken,
        displayName: displayName,
        photoUrl: photoUrl,
      );

      // Update local storage
      await _localDatasource.updateUser(
        displayName: displayName,
        photoUrl: photoUrl,
      );

      return right(updatedUser.toEntity());
    } on AuthException catch (e) {
      return left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return left(AuthFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetCode({
    required String email,
  }) async {
    try {
      // Validate email format
      if (!_isValidEmail(email)) {
        return left(ValidationFailure.invalidEmail());
      }

      // Send reset code via remote datasource
      await _remoteDatasource.sendPasswordResetCode(email);

      return right(unit);
    } on AuthException catch (e) {
      return left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return left(AuthFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    try {
      // Validate email format
      if (!_isValidEmail(email)) {
        return left(ValidationFailure.invalidEmail());
      }

      // Validate code format (6 digits)
      if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
        return left(ValidationFailure(
          message: 'Code must be 6 digits',
          code: 'invalid_code',
        ));
      }

      // Verify code via remote datasource
      await _remoteDatasource.verifyPasswordResetCode(
        email: email,
        code: code,
      );

      return right(unit);
    } on AuthException catch (e) {
      return left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return left(AuthFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      // Validate email format
      if (!_isValidEmail(email)) {
        return left(ValidationFailure.invalidEmail());
      }

      // Validate code format
      if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
        return left(ValidationFailure(
          message: 'Code must be 6 digits',
          code: 'invalid_code',
        ));
      }

      // Validate password strength
      if (!_isValidPassword(newPassword)) {
        return left(ValidationFailure.weakPassword());
      }

      // Reset password via remote datasource
      await _remoteDatasource.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );

      return right(unit);
    } on AuthException catch (e) {
      return left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return left(AuthFailure.unknown(e.toString()));
    }
  }

  /// Saves authentication result to local storage
  Future<void> _saveAuthResult(AuthResult result) async {
    await Future.wait([
      _localDatasource.saveUser(UserModel.fromEntity(result.user)),
      _localDatasource.saveTokens(AuthTokensModel.fromEntity(result.tokens)),
    ]);
  }

  /// Validates email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  /// Validates password strength
  /// At least 8 characters, one number, one special character
  bool _isValidPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }
}
