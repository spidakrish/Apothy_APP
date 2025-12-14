import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/user.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

/// Exception thrown when authentication fails
class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' ($code)' : ''}';
}

/// Remote data source for authentication API calls
abstract class AuthRemoteDatasource {
  /// Authenticates user with Apple Sign-In identity token
  Future<AuthResult> signInWithApple({
    required String identityToken,
    required String authorizationCode,
    String? email,
    String? fullName,
  });

  /// Authenticates user with Google Sign-In ID token
  Future<AuthResult> signInWithGoogle({
    required String idToken,
    required String accessToken,
  });

  /// Authenticates user with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  });

  /// Registers a new user with email and password
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Refreshes the access token using refresh token
  Future<AuthTokensModel> refreshToken(String refreshToken);

  /// Signs out the user (invalidates tokens on backend)
  Future<void> signOut(String accessToken);

  /// Gets the current user profile
  Future<UserModel> getUser(String accessToken);

  /// Updates user profile (display name, avatar)
  Future<UserModel> updateProfile({
    required String accessToken,
    String? displayName,
    String? photoUrl,
  });

  /// Deletes user account permanently
  /// Required for GDPR compliance and App Store requirements
  Future<void> deleteAccount(String accessToken);

  /// Sends a password reset code to the user's email
  Future<void> sendPasswordResetCode(String email);

  /// Verifies the password reset code
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  });

  /// Resets the password with the verified code
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}

/// Result of an authentication operation
class AuthResult {
  const AuthResult({required this.user, required this.tokens});

  final UserModel user;
  final AuthTokensModel tokens;
}

/// Implementation of AuthRemoteDatasource using Dio
///
/// NOTE: Backend endpoints don't exist yet. This implementation
/// is designed to work when endpoints are added. Currently uses
/// mock responses for development.
class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  AuthRemoteDatasourceImpl({
    Dio? dio,
    this.useMock = false, // Using real authentication now
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: ApiConstants.baseUrl,
               connectTimeout: Duration(
                 seconds: ApiConstants.connectionTimeout,
               ),
               receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
               headers: {
                 'Content-Type': 'application/json',
                 'Accept': 'application/json',
               },
             ),
           );

  final Dio _dio;
  final bool useMock;

  // Expected endpoint paths (to be implemented on backend)
  static const String _appleSignInPath = '/auth/mobile/apple';
  static const String _googleSignInPath = '/auth/mobile/google';
  static const String _emailSignInPath = '/auth/mobile/email/login';
  static const String _emailSignUpPath = '/auth/mobile/email/register';
  static const String _refreshTokenPath = '/auth/refresh';
  static const String _signOutPath = '/auth/logout';
  static const String _deleteAccountPath = '/auth/delete';
  static const String _userPath = '/user';
  static const String _updateProfilePath = '/user/profile';
  static const String _passwordResetPath = '/auth/password/reset/send';
  static const String _passwordResetVerifyPath = '/auth/password/reset/verify';
  static const String _passwordResetConfirmPath =
      '/auth/password/reset/confirm';

  @override
  Future<AuthResult> signInWithApple({
    required String identityToken,
    required String authorizationCode,
    String? email,
    String? fullName,
  }) async {
    if (useMock) {
      return _mockAuthResult(
        AuthProvider.apple,
        email: email,
        displayName: fullName,
      );
    }

    try {
      final response = await _dio.post(
        _appleSignInPath,
        data: {
          'identity_token': identityToken,
          'authorization_code': authorizationCode,
          if (email != null) 'email': email,
          if (fullName != null) 'full_name': fullName,
        },
      );
      return _parseAuthResult(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<AuthResult> signInWithGoogle({
    required String idToken,
    required String accessToken,
  }) async {
    if (useMock) {
      return _mockAuthResult(AuthProvider.google);
    }

    try {
      final response = await _dio.post(
        _googleSignInPath,
        data: {'id_token': idToken, 'access_token': accessToken},
      );
      return _parseAuthResult(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (useMock) {
      return _mockAuthResult(AuthProvider.email, email: email);
    }

    try {
      final response = await _dio.post(
        _emailSignInPath,
        data: {'email': email, 'password': password},
      );
      return _parseAuthResult(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (useMock) {
      return _mockAuthResult(
        AuthProvider.email,
        email: email,
        displayName: displayName,
      );
    }

    try {
      final response = await _dio.post(
        _emailSignUpPath,
        data: {
          'email': email,
          'password': password,
          if (displayName != null) 'display_name': displayName,
        },
      );
      return _parseAuthResult(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    if (useMock) {
      return AuthTokensModel(
        accessToken:
            'mock_refreshed_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: refreshToken,
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
    }

    try {
      final response = await _dio.post(
        _refreshTokenPath,
        data: {'refresh_token': refreshToken},
      );
      return AuthTokensModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> signOut(String accessToken) async {
    if (useMock) {
      return; // Mock: just return success
    }

    try {
      await _dio.post(
        _signOutPath,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } on DioException catch (e) {
      // Log but don't throw - logout should succeed locally even if backend fails
      // ignore: avoid_print
      print('Sign out API call failed: ${e.message}');
    }
  }

  @override
  Future<UserModel> getUser(String accessToken) async {
    if (useMock) {
      return const UserModel(
        id: 'mock_user_id',
        email: 'mock@apothy.ai',
        displayName: 'Mock User',
        provider: AuthProvider.email,
      );
    }

    try {
      final response = await _dio.get(
        _userPath,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String accessToken,
    String? displayName,
    String? photoUrl,
  }) async {
    if (useMock) {
      // Mock: return updated user with new values
      return UserModel(
        id: 'mock_user_id',
        email: 'mock@apothy.ai',
        displayName: displayName ?? 'Mock User',
        photoUrl: photoUrl,
        provider: AuthProvider.email,
      );
    }

    try {
      final response = await _dio.patch(
        _updateProfilePath,
        data: {
          if (displayName != null) 'display_name': displayName,
          if (photoUrl != null) 'photo_url': photoUrl,
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteAccount(String accessToken) async {
    if (useMock) {
      // Mock: simulate successful account deletion
      return;
    }

    try {
      await _dio.delete(
        _deleteAccountPath,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Parses API response into AuthResult
  AuthResult _parseAuthResult(Map<String, dynamic> data) {
    final user = UserModel.fromJson(data['user'] ?? data);
    final tokens = AuthTokensModel.fromJson(data['tokens'] ?? data);
    return AuthResult(user: user, tokens: tokens);
  }

  /// Creates mock auth result for development
  AuthResult _mockAuthResult(
    AuthProvider provider, {
    String? email,
    String? displayName,
  }) {
    final now = DateTime.now();
    final userId = 'mock_${provider.name}_${now.millisecondsSinceEpoch}';

    return AuthResult(
      user: UserModel(
        id: userId,
        email: email ?? 'user@apothy.ai',
        displayName: displayName ?? 'Apothy User',
        provider: provider,
        createdAt: now,
        lastLoginAt: now,
      ),
      tokens: AuthTokensModel(
        accessToken: 'mock_access_token_$userId',
        refreshToken: 'mock_refresh_token_$userId',
        expiresAt: now.add(const Duration(hours: 1)),
      ),
    );
  }

  @override
  Future<void> sendPasswordResetCode(String email) async {
    if (useMock) {
      // Mock: Simulate sending password reset code
      await Future.delayed(const Duration(seconds: 1));

      // Simulate email validation
      if (!email.contains('@')) {
        throw const AuthException(
          'Invalid email address',
          code: 'invalid_email',
        );
      }

      // In mock mode, we just log the code (in production, backend sends email)
      final mockCode = '123456';
      print('Mock password reset code for $email: $mockCode');
      return;
    }

    try {
      await _dio.post(_passwordResetPath, data: {'email': email});
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    if (useMock) {
      // Mock: Validate code format
      await Future.delayed(const Duration(milliseconds: 500));

      if (code.length != 6) {
        throw const AuthException(
          'Code must be 6 digits',
          code: 'invalid_code',
        );
      }

      // Mock: Accept code '123456' for testing
      if (code != '123456') {
        throw const AuthException(
          'Invalid or expired code',
          code: 'invalid_code',
        );
      }

      return;
    }

    try {
      await _dio.post(
        _passwordResetVerifyPath,
        data: {'email': email, 'code': code},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    if (useMock) {
      // Mock: Simulate password reset
      await Future.delayed(const Duration(seconds: 1));

      // Validate password strength
      if (newPassword.length < 8) {
        throw const AuthException(
          'Password must be at least 8 characters',
          code: 'weak_password',
        );
      }

      // Mock: Verify code again
      if (code != '123456') {
        throw const AuthException(
          'Invalid or expired code',
          code: 'invalid_code',
        );
      }

      print('Mock password reset successful for $email');
      return;
    }

    try {
      await _dio.post(
        _passwordResetConfirmPath,
        data: {'email': email, 'code': code, 'new_password': newPassword},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handles Dio errors and converts to AuthException
  AuthException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AuthException(
          'Connection timed out. Please check your internet connection.',
          code: 'timeout',
        );
      case DioExceptionType.connectionError:
        return const AuthException(
          'Unable to connect to server. Please check your internet connection.',
          code: 'connection_error',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (statusCode == 401) {
          return AuthException(
            data?['message'] ?? 'Invalid credentials',
            code: 'unauthorized',
          );
        } else if (statusCode == 403) {
          return AuthException(
            data?['message'] ?? 'Access denied',
            code: 'forbidden',
          );
        } else if (statusCode == 404) {
          return const AuthException(
            'Service not available',
            code: 'not_found',
          );
        } else if (statusCode == 409) {
          return AuthException(
            data?['message'] ?? 'Account already exists',
            code: 'conflict',
          );
        } else if (statusCode == 422) {
          return AuthException(
            data?['message'] ?? 'Invalid request data',
            code: 'validation_error',
          );
        } else if (statusCode != null && statusCode >= 500) {
          return const AuthException(
            'Server error. Please try again later.',
            code: 'server_error',
          );
        }
        return AuthException(
          data?['message'] ?? 'An error occurred',
          code: 'unknown',
        );
      case DioExceptionType.cancel:
        return const AuthException('Request was cancelled', code: 'cancelled');
      default:
        return AuthException(
          e.message ?? 'An unexpected error occurred',
          code: 'unknown',
        );
    }
  }
}
