import 'package:equatable/equatable.dart';

/// Authentication tokens from the backend
class AuthTokens extends Equatable {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  /// JWT access token for API authentication
  final String accessToken;

  /// Refresh token for obtaining new access tokens
  final String refreshToken;

  /// When the access token expires
  final DateTime expiresAt;

  /// Empty tokens (for unauthenticated state)
  static final empty = AuthTokens(
    accessToken: '',
    refreshToken: '',
    expiresAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Whether these tokens are empty
  bool get isEmpty => accessToken.isEmpty;

  /// Whether these tokens are not empty
  bool get isNotEmpty => !isEmpty;

  /// Whether the access token has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Whether the access token is still valid
  bool get isValid => isNotEmpty && !isExpired;

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt];

  /// Creates a copy with updated fields
  AuthTokens copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) {
    return AuthTokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
