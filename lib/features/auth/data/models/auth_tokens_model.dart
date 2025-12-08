import '../../domain/entities/auth_tokens.dart';

/// Data model for AuthTokens with JSON serialization
class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
    required super.expiresAt,
  });

  /// Creates AuthTokensModel from JSON response
  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    // Parse expires_at - could be ISO string or Unix timestamp
    DateTime expiresAt;
    final expiresAtValue = json['expires_at'] ?? json['expiresAt'];

    if (expiresAtValue is int) {
      // Unix timestamp in seconds
      expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresAtValue * 1000);
    } else if (expiresAtValue is String) {
      // ISO 8601 string
      expiresAt = DateTime.tryParse(expiresAtValue) ??
          DateTime.now().add(const Duration(hours: 1));
    } else if (json['expires_in'] != null) {
      // Duration in seconds from now
      final expiresIn = json['expires_in'] as int;
      expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    } else {
      // Default to 1 hour from now
      expiresAt = DateTime.now().add(const Duration(hours: 1));
    }

    return AuthTokensModel(
      accessToken: json['access_token'] as String? ??
          json['accessToken'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ??
          json['refreshToken'] as String? ?? '',
      expiresAt: expiresAt,
    );
  }

  /// Converts AuthTokensModel to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  /// Creates AuthTokensModel from an AuthTokens entity
  factory AuthTokensModel.fromEntity(AuthTokens tokens) {
    return AuthTokensModel(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresAt: tokens.expiresAt,
    );
  }

  /// Converts to AuthTokens entity
  AuthTokens toEntity() {
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }

  /// Empty tokens model
  static final empty = AuthTokensModel(
    accessToken: '',
    refreshToken: '',
    expiresAt: DateTime.fromMillisecondsSinceEpoch(0),
  );
}
