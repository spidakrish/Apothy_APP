import 'package:hive/hive.dart';

import '../../domain/entities/subscription.dart';

part 'subscription_model.g.dart';

/// Hive type IDs for subscription feature
abstract class SubscriptionHiveTypeIds {
  static const int subscriptionModel = 40;
  static const int subscriptionTierAdapter = 41;
  static const int subscriptionStatusAdapter = 42;
}

/// Hive adapter for SubscriptionTier enum
@HiveType(typeId: SubscriptionHiveTypeIds.subscriptionTierAdapter)
enum SubscriptionTierHive {
  @HiveField(0)
  free,
  @HiveField(1)
  plus,
  @HiveField(2)
  pro;

  SubscriptionTier toEntity() {
    switch (this) {
      case SubscriptionTierHive.free:
        return SubscriptionTier.free;
      case SubscriptionTierHive.plus:
        return SubscriptionTier.plus;
      case SubscriptionTierHive.pro:
        return SubscriptionTier.pro;
    }
  }

  static SubscriptionTierHive fromEntity(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return SubscriptionTierHive.free;
      case SubscriptionTier.plus:
        return SubscriptionTierHive.plus;
      case SubscriptionTier.pro:
        return SubscriptionTierHive.pro;
    }
  }
}

/// Hive adapter for SubscriptionStatus enum
@HiveType(typeId: SubscriptionHiveTypeIds.subscriptionStatusAdapter)
enum SubscriptionStatusHive {
  @HiveField(0)
  active,
  @HiveField(1)
  expired,
  @HiveField(2)
  cancelled,
  @HiveField(3)
  trial,
  @HiveField(4)
  gracePeriod;

  SubscriptionStatus toEntity() {
    switch (this) {
      case SubscriptionStatusHive.active:
        return SubscriptionStatus.active;
      case SubscriptionStatusHive.expired:
        return SubscriptionStatus.expired;
      case SubscriptionStatusHive.cancelled:
        return SubscriptionStatus.cancelled;
      case SubscriptionStatusHive.trial:
        return SubscriptionStatus.trial;
      case SubscriptionStatusHive.gracePeriod:
        return SubscriptionStatus.gracePeriod;
    }
  }

  static SubscriptionStatusHive fromEntity(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return SubscriptionStatusHive.active;
      case SubscriptionStatus.expired:
        return SubscriptionStatusHive.expired;
      case SubscriptionStatus.cancelled:
        return SubscriptionStatusHive.cancelled;
      case SubscriptionStatus.trial:
        return SubscriptionStatusHive.trial;
      case SubscriptionStatus.gracePeriod:
        return SubscriptionStatusHive.gracePeriod;
    }
  }
}

/// Hive model for storing subscription data locally
@HiveType(typeId: SubscriptionHiveTypeIds.subscriptionModel)
class SubscriptionModel extends HiveObject {
  SubscriptionModel({
    required this.tier,
    required this.status,
    this.expiresAt,
    this.willRenew = false,
    this.productId,
    this.originalPurchaseDate,
    this.lastSyncedAt,
  });

  /// The subscription tier level
  @HiveField(0)
  SubscriptionTierHive tier;

  /// The current subscription status
  @HiveField(1)
  SubscriptionStatusHive status;

  /// When the subscription expires (null for free tier)
  @HiveField(2)
  DateTime? expiresAt;

  /// Whether the subscription will auto-renew
  @HiveField(3)
  bool willRenew;

  /// The product identifier from App Store / Play Store
  @HiveField(4)
  String? productId;

  /// When the subscription was originally purchased
  @HiveField(5)
  DateTime? originalPurchaseDate;

  /// Last time this was synced with RevenueCat (for cache invalidation)
  @HiveField(6)
  DateTime? lastSyncedAt;

  /// Convert to domain entity
  Subscription toEntity() {
    return Subscription(
      tier: tier.toEntity(),
      status: status.toEntity(),
      expiresAt: expiresAt,
      willRenew: willRenew,
      productId: productId,
      originalPurchaseDate: originalPurchaseDate,
    );
  }

  /// Create from domain entity
  factory SubscriptionModel.fromEntity(Subscription subscription) {
    return SubscriptionModel(
      tier: SubscriptionTierHive.fromEntity(subscription.tier),
      status: SubscriptionStatusHive.fromEntity(subscription.status),
      expiresAt: subscription.expiresAt,
      willRenew: subscription.willRenew,
      productId: subscription.productId,
      originalPurchaseDate: subscription.originalPurchaseDate,
      lastSyncedAt: DateTime.now(),
    );
  }

  /// Check if cached subscription is still valid (< 1 hour old)
  bool get isCacheValid {
    if (lastSyncedAt == null) return false;
    final age = DateTime.now().difference(lastSyncedAt!);
    return age.inHours < 1;
  }
}
