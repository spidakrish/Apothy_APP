import '../../domain/entities/user.dart';
import '../../../subscription/domain/entities/subscription.dart';

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
    super.subscriptionTier,
    super.subscriptionExpiresAt,
    super.isSubscriptionActive,
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
      subscriptionTier: _parseSubscriptionTier(json['subscription_tier'] as String?),
      subscriptionExpiresAt: json['subscription_expires_at'] != null
          ? DateTime.tryParse(json['subscription_expires_at'] as String)
          : null,
      isSubscriptionActive: json['is_subscription_active'] as bool? ?? true,
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
      'subscription_tier': subscriptionTier.name,
      'subscription_expires_at': subscriptionExpiresAt?.toIso8601String(),
      'is_subscription_active': isSubscriptionActive,
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
      subscriptionTier: user.subscriptionTier,
      subscriptionExpiresAt: user.subscriptionExpiresAt,
      isSubscriptionActive: user.isSubscriptionActive,
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
      subscriptionTier: subscriptionTier,
      subscriptionExpiresAt: subscriptionExpiresAt,
      isSubscriptionActive: isSubscriptionActive,
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

  /// Parses subscription tier string to enum
  static SubscriptionTier _parseSubscriptionTier(String? tier) {
    switch (tier?.toLowerCase()) {
      case 'plus':
        return SubscriptionTier.plus;
      case 'pro':
        return SubscriptionTier.pro;
      case 'free':
      default:
        return SubscriptionTier.free;
    }
  }
}
