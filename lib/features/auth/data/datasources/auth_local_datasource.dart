import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

/// Keys for secure storage
abstract class AuthStorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenExpiresAt = 'token_expires_at';
  static const String user = 'user';
  static const String hasCompletedOnboarding = 'has_completed_onboarding';
  static const String hasCompletedMirrorIntro = 'has_completed_mirror_intro';
}

/// Local data source for authentication using secure storage
///
/// Uses flutter_secure_storage which:
/// - iOS: Stores in Keychain
/// - Android: Encrypts data and stores in SharedPreferences with key in KeyStore
abstract class AuthLocalDatasource {
  /// Saves authentication tokens securely
  Future<void> saveTokens(AuthTokensModel tokens);

  /// Retrieves stored tokens, returns null if not found
  Future<AuthTokensModel?> getTokens();

  /// Deletes stored tokens
  Future<void> deleteTokens();

  /// Saves user data
  Future<void> saveUser(UserModel user);

  /// Retrieves stored user, returns null if not found
  Future<UserModel?> getUser();

  /// Updates specific user fields (display name, avatar)
  Future<void> updateUser({
    String? displayName,
    String? photoUrl,
  });

  /// Deletes stored user data
  Future<void> deleteUser();

  /// Clears all auth-related data (for logout)
  Future<void> clearAll();

  /// Checks if user has completed onboarding
  Future<bool> hasCompletedOnboarding();

  /// Marks onboarding as completed
  Future<void> setOnboardingCompleted();

  /// Clears onboarding status (for deep reset)
  Future<void> clearOnboarding();

  /// Clears ALL data including onboarding (for deep reset / account deletion)
  Future<void> clearAllIncludingOnboarding();

  /// Checks if user has completed mirror introduction
  Future<bool> hasCompletedMirrorIntro();

  /// Marks mirror introduction as completed
  Future<void> setMirrorIntroCompleted();

  /// Clears mirror introduction status (for testing / reset)
  Future<void> clearMirrorIntro();
}

/// Implementation of AuthLocalDatasource using flutter_secure_storage
class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  AuthLocalDatasourceImpl({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final FlutterSecureStorage _storage;

  @override
  Future<void> saveTokens(AuthTokensModel tokens) async {
    await Future.wait([
      _storage.write(
        key: AuthStorageKeys.accessToken,
        value: tokens.accessToken,
      ),
      _storage.write(
        key: AuthStorageKeys.refreshToken,
        value: tokens.refreshToken,
      ),
      _storage.write(
        key: AuthStorageKeys.tokenExpiresAt,
        value: tokens.expiresAt.toIso8601String(),
      ),
    ]);
  }

  @override
  Future<AuthTokensModel?> getTokens() async {
    final results = await Future.wait([
      _storage.read(key: AuthStorageKeys.accessToken),
      _storage.read(key: AuthStorageKeys.refreshToken),
      _storage.read(key: AuthStorageKeys.tokenExpiresAt),
    ]);

    final accessToken = results[0];
    final refreshToken = results[1];
    final expiresAtString = results[2];

    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    DateTime expiresAt;
    if (expiresAtString != null) {
      expiresAt = DateTime.tryParse(expiresAtString) ??
          DateTime.now().add(const Duration(hours: 1));
    } else {
      expiresAt = DateTime.now().add(const Duration(hours: 1));
    }

    return AuthTokensModel(
      accessToken: accessToken,
      refreshToken: refreshToken ?? '',
      expiresAt: expiresAt,
    );
  }

  @override
  Future<void> deleteTokens() async {
    await Future.wait([
      _storage.delete(key: AuthStorageKeys.accessToken),
      _storage.delete(key: AuthStorageKeys.refreshToken),
      _storage.delete(key: AuthStorageKeys.tokenExpiresAt),
    ]);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: AuthStorageKeys.user, value: userJson);
  }

  @override
  Future<UserModel?> getUser() async {
    final userJson = await _storage.read(key: AuthStorageKeys.user);
    if (userJson == null || userJson.isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> json = jsonDecode(userJson);
      return UserModel.fromJson(json);
    } catch (e) {
      // If parsing fails, delete corrupted data
      await _storage.delete(key: AuthStorageKeys.user);
      return null;
    }
  }

  @override
  Future<void> updateUser({
    String? displayName,
    String? photoUrl,
  }) async {
    final currentUser = await getUser();
    if (currentUser == null) {
      throw Exception('No user to update');
    }

    // Create updated user with new values
    final updatedUser = UserModel(
      id: currentUser.id,
      email: currentUser.email,
      displayName: displayName ?? currentUser.displayName,
      photoUrl: photoUrl ?? currentUser.photoUrl,
      provider: currentUser.provider,
      createdAt: currentUser.createdAt,
      lastLoginAt: currentUser.lastLoginAt,
      subscriptionTier: currentUser.subscriptionTier,
      subscriptionExpiresAt: currentUser.subscriptionExpiresAt,
      isSubscriptionActive: currentUser.isSubscriptionActive,
    );

    await saveUser(updatedUser);
  }

  @override
  Future<void> deleteUser() async {
    await _storage.delete(key: AuthStorageKeys.user);
  }

  @override
  Future<void> clearAll() async {
    await Future.wait([
      deleteTokens(),
      deleteUser(),
      // Note: We don't clear onboarding status on logout
    ]);
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    final value = await _storage.read(key: AuthStorageKeys.hasCompletedOnboarding);
    return value == 'true';
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await _storage.write(
      key: AuthStorageKeys.hasCompletedOnboarding,
      value: 'true',
    );
  }

  @override
  Future<void> clearOnboarding() async {
    await _storage.delete(key: AuthStorageKeys.hasCompletedOnboarding);
  }

  @override
  Future<void> clearAllIncludingOnboarding() async {
    await Future.wait([
      deleteTokens(),
      deleteUser(),
      clearOnboarding(),
    ]);
  }

  @override
  Future<bool> hasCompletedMirrorIntro() async {
    final value = await _storage.read(key: AuthStorageKeys.hasCompletedMirrorIntro);
    return value == 'true';
  }

  @override
  Future<void> setMirrorIntroCompleted() async {
    await _storage.write(
      key: AuthStorageKeys.hasCompletedMirrorIntro,
      value: 'true',
    );
  }

  @override
  Future<void> clearMirrorIntro() async {
    await _storage.delete(key: AuthStorageKeys.hasCompletedMirrorIntro);
  }
}
