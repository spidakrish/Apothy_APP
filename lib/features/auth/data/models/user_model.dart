import '../../domain/entities/user.dart';

/// Data model for User entity with JSON serialization
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    required super.provider,
    super.createdAt,
    super.lastLoginAt,
  });

  /// Creates a UserModel from JSON response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['user_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String? ?? json['name'] as String?,
      photoUrl: json['photo_url'] as String? ?? json['avatar'] as String?,
      provider: _parseProvider(json['provider'] as String?),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.tryParse(json['last_login_at'] as String)
          : null,
    );
  }

  /// Converts UserModel to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'provider': provider.name,
      'created_at': createdAt?.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  /// Creates a UserModel from a User entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      provider: user.provider,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
    );
  }

  /// Converts to User entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      provider: provider,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  /// Parses provider string to enum
  static AuthProvider _parseProvider(String? provider) {
    switch (provider?.toLowerCase()) {
      case 'apple':
        return AuthProvider.apple;
      case 'google':
        return AuthProvider.google;
      case 'email':
      default:
        return AuthProvider.email;
    }
  }
}
