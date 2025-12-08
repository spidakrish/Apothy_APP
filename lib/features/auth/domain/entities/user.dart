import 'package:equatable/equatable.dart';

/// Authentication provider types
enum AuthProvider {
  apple,
  google,
  email,
}

/// User entity representing an authenticated user
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.provider,
    this.createdAt,
    this.lastLoginAt,
  });

  /// Unique user identifier from backend
  final String id;

  /// User's email address
  final String email;

  /// User's display name (optional)
  final String? displayName;

  /// URL to user's profile photo (optional)
  final String? photoUrl;

  /// Authentication provider used
  final AuthProvider provider;

  /// When the user account was created
  final DateTime? createdAt;

  /// Last login timestamp
  final DateTime? lastLoginAt;

  /// Creates an empty user (for unauthenticated state)
  static const empty = User(
    id: '',
    email: '',
    provider: AuthProvider.email,
  );

  /// Whether this user is empty/unauthenticated
  bool get isEmpty => id.isEmpty;

  /// Whether this user is not empty/authenticated
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        provider,
        createdAt,
        lastLoginAt,
      ];

  /// Creates a copy with updated fields
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    AuthProvider? provider,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
