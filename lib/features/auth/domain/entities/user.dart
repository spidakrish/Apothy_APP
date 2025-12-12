import 'package:equatable/equatable.dart';

import '../../../subscription/domain/entities/subscription.dart';

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
    this.subscriptionTier = SubscriptionTier.free,
    this.subscriptionExpiresAt,
    this.isSubscriptionActive = true,
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

  /// Subscription tier level
  final SubscriptionTier subscriptionTier;

  /// When the subscription expires (null for free tier)
  final DateTime? subscriptionExpiresAt;

  /// Whether the subscription is currently active
  final bool isSubscriptionActive;

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

  /// Whether user has premium access (Plus or Pro tier with active subscription)
  bool get isPremium =>
      subscriptionTier != SubscriptionTier.free && isSubscriptionActive;

  /// Whether user has Pro tier access
  bool get isPro =>
      subscriptionTier == SubscriptionTier.pro && isSubscriptionActive;

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        provider,
        createdAt,
        lastLoginAt,
        subscriptionTier,
        subscriptionExpiresAt,
        isSubscriptionActive,
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
    SubscriptionTier? subscriptionTier,
    DateTime? subscriptionExpiresAt,
    bool? isSubscriptionActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      isSubscriptionActive: isSubscriptionActive ?? this.isSubscriptionActive,
    );
  }
}
