import 'package:equatable/equatable.dart';

/// Subscription tier levels
enum SubscriptionTier {
  /// Free tier with limited features
  free,

  /// Plus tier with full features
  plus,

  /// Pro tier with all features + premium support
  pro;

  /// Check if this tier is free
  bool get isFree => this == SubscriptionTier.free;

  /// Check if this tier has premium features
  bool get isPremium => this == plus || this == pro;

  /// Check if this tier is Pro
  bool get isPro => this == SubscriptionTier.pro;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.plus:
        return 'Plus';
      case SubscriptionTier.pro:
        return 'Pro';
    }
  }
}

/// Subscription status states
enum SubscriptionStatus {
  /// Active subscription
  active,

  /// Expired subscription
  expired,

  /// Cancelled (will expire at end of period)
  cancelled,

  /// In trial period
  trial,

  /// Grace period after payment failure
  gracePeriod;

  /// Check if subscription is currently active
  bool get isActive => this == active || this == trial || this == gracePeriod;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.trial:
        return 'Trial';
      case SubscriptionStatus.gracePeriod:
        return 'Grace Period';
    }
  }
}

/// Subscription entity representing a user's subscription state
class Subscription extends Equatable {
  const Subscription({
    required this.tier,
    required this.status,
    this.expiresAt,
    this.willRenew = false,
    this.productId,
    this.originalPurchaseDate,
  });

  /// Factory constructor for free tier (default)
  factory Subscription.free() => const Subscription(
        tier: SubscriptionTier.free,
        status: SubscriptionStatus.active,
      );

  /// The subscription tier level
  final SubscriptionTier tier;

  /// The current subscription status
  final SubscriptionStatus status;

  /// When the subscription expires (null for free tier)
  final DateTime? expiresAt;

  /// Whether the subscription will auto-renew
  final bool willRenew;

  /// The product identifier from App Store / Play Store
  final String? productId;

  /// When the subscription was originally purchased
  final DateTime? originalPurchaseDate;

  // Convenience getters

  /// Check if subscription is currently active
  bool get isActive => status.isActive;

  /// Check if user has premium access
  bool get isPremium => tier.isPremium && isActive;

  /// Check if user has pro access
  bool get isPro => tier.isPro && isActive;

  /// Check if subscription has expired
  bool get isExpired {
    if (tier == SubscriptionTier.free) return false;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Days until expiration (null if free or no expiration date)
  int? get daysUntilExpiration {
    if (expiresAt == null) return null;
    return expiresAt!.difference(DateTime.now()).inDays;
  }

  /// Check if subscription is in final days (less than 7 days)
  bool get isInFinalDays {
    final days = daysUntilExpiration;
    return days != null && days < 7 && days >= 0;
  }

  @override
  List<Object?> get props => [
        tier,
        status,
        expiresAt,
        willRenew,
        productId,
        originalPurchaseDate,
      ];

  @override
  String toString() {
    return 'Subscription(tier: $tier, status: $status, expiresAt: $expiresAt, '
        'willRenew: $willRenew, productId: $productId)';
  }

  /// Copy with method for immutable updates
  Subscription copyWith({
    SubscriptionTier? tier,
    SubscriptionStatus? status,
    DateTime? expiresAt,
    bool? willRenew,
    String? productId,
    DateTime? originalPurchaseDate,
  }) {
    return Subscription(
      tier: tier ?? this.tier,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      willRenew: willRenew ?? this.willRenew,
      productId: productId ?? this.productId,
      originalPurchaseDate: originalPurchaseDate ?? this.originalPurchaseDate,
    );
  }
}
