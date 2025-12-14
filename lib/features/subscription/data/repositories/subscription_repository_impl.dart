import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/config/revenue_cat_config.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_local_datasource.dart';
import '../models/subscription_model.dart';

/// Implementation of SubscriptionRepository using RevenueCat and local cache
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({
    required SubscriptionLocalDatasource localDatasource,
  }) : _localDatasource = localDatasource;

  final SubscriptionLocalDatasource _localDatasource;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      await _localDatasource.initialize();
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to initialize subscription storage: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Subscription>> getSubscription() async {
    try {
      // 1. Try to get cached subscription
      final cached = await _localDatasource.getSubscription();
      if (cached != null && cached.isCacheValid) {
        return Right(cached.toEntity());
      }

      // 2. Fetch from RevenueCat
      final customerInfo = await Purchases.getCustomerInfo();
      final subscription = _parseCustomerInfo(customerInfo);

      // 3. Save to cache
      await _localDatasource.saveSubscription(
        SubscriptionModel.fromEntity(subscription),
      );

      // 4. Sync with backend (fire and forget)
      _syncWithBackend(subscription);

      return Right(subscription);
    } on PlatformException catch (e) {
      // RevenueCat errors
      return Left(
        SubscriptionFailure(
          message: 'Failed to fetch subscription: ${e.message}',
        ),
      );
    } catch (e) {
      return Left(
        SubscriptionFailure(message: 'Unexpected error: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Package>>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();

      if (offerings.current == null) {
        return const Right([]);
      }

      // Return all available packages
      final packages = offerings.current!.availablePackages;
      return Right(packages);
    } on PlatformException catch (e) {
      return Left(
        SubscriptionFailure(
          message: 'Failed to fetch offerings: ${e.message}',
        ),
      );
    } catch (e) {
      return Left(
        SubscriptionFailure(message: 'Unexpected error: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Subscription>> purchasePackage(Package package) async {
    try {
      // Attempt purchase
      final purchaserInfo = await Purchases.purchasePackage(package);
      final subscription = _parseCustomerInfo(purchaserInfo.customerInfo);

      // Save to cache
      await _localDatasource.saveSubscription(
        SubscriptionModel.fromEntity(subscription),
      );

      // Sync with backend
      await _syncWithBackend(subscription);

      return Right(subscription);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      // User cancelled
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return Left(
          SubscriptionFailure(message: 'Purchase cancelled'),
        );
      }

      // Payment invalid
      if (errorCode == PurchasesErrorCode.paymentPendingError) {
        return Left(
          SubscriptionFailure(message: 'Payment pending'),
        );
      }

      // Product already owned
      if (errorCode == PurchasesErrorCode.productAlreadyPurchasedError) {
        return Left(
          SubscriptionFailure(message: 'Already subscribed to this tier'),
        );
      }

      return Left(
        SubscriptionFailure(
          message: 'Purchase failed: ${e.message}',
        ),
      );
    } catch (e) {
      return Left(
        SubscriptionFailure(message: 'Unexpected error: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Subscription>> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final subscription = _parseCustomerInfo(customerInfo);

      // Save to cache
      await _localDatasource.saveSubscription(
        SubscriptionModel.fromEntity(subscription),
      );

      // Sync with backend
      await _syncWithBackend(subscription);

      return Right(subscription);
    } on PlatformException catch (e) {
      return Left(
        SubscriptionFailure(
          message: 'Failed to restore purchases: ${e.message}',
        ),
      );
    } catch (e) {
      return Left(
        SubscriptionFailure(message: 'Unexpected error: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> syncWithBackend() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final subscription = _parseCustomerInfo(customerInfo);

      await _syncWithBackend(subscription);

      return const Right(null);
    } catch (e) {
      return Left(
        SubscriptionFailure(message: 'Failed to sync: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await _localDatasource.clearSubscription();
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to clear cache: $e'),
      );
    }
  }

  /// Parse RevenueCat CustomerInfo into Subscription entity
  Subscription _parseCustomerInfo(CustomerInfo info) {
    final entitlements = info.entitlements.active;

    // Check for Pro entitlement first (higher tier)
    if (entitlements.containsKey(RevenueCatConfig.proEntitlement)) {
      final entitlement = entitlements[RevenueCatConfig.proEntitlement]!;
      return Subscription(
        tier: SubscriptionTier.pro,
        status: _parseStatus(entitlement),
        expiresAt: entitlement.expirationDate != null ? DateTime.parse(entitlement.expirationDate!) : null,
        willRenew: entitlement.willRenew,
        productId: entitlement.productIdentifier,
        originalPurchaseDate: DateTime.parse(entitlement.originalPurchaseDate),
      );
    }

    // Check for Plus entitlement
    if (entitlements.containsKey(RevenueCatConfig.plusEntitlement)) {
      final entitlement = entitlements[RevenueCatConfig.plusEntitlement]!;
      return Subscription(
        tier: SubscriptionTier.plus,
        status: _parseStatus(entitlement),
        expiresAt: entitlement.expirationDate != null ? DateTime.parse(entitlement.expirationDate!) : null,
        willRenew: entitlement.willRenew,
        productId: entitlement.productIdentifier,
        originalPurchaseDate: DateTime.parse(entitlement.originalPurchaseDate),
      );
    }

    // Default to free tier
    return Subscription.free();
  }

  /// Parse entitlement info into subscription status
  SubscriptionStatus _parseStatus(EntitlementInfo entitlement) {
    // In trial period
    if (entitlement.periodType == PeriodType.trial) {
      return SubscriptionStatus.trial;
    }

    // Billing issue but still in grace period
    if (entitlement.billingIssueDetectedAt != null) {
      return SubscriptionStatus.gracePeriod;
    }

    // Will renew
    if (entitlement.willRenew) {
      return SubscriptionStatus.active;
    }

    // Will not renew (cancelled but still active until expiration)
    if (entitlement.expirationDate != null &&
        DateTime.now().isBefore(DateTime.parse(entitlement.expirationDate!))) {
      return SubscriptionStatus.cancelled;
    }

    // Expired
    return SubscriptionStatus.expired;
  }

  /// Sync subscription with backend (fire and forget)
  ///
  /// TODO: Implement backend API call when backend is ready
  Future<void> _syncWithBackend(Subscription subscription) async {
    // Fire and forget - don't wait for response
    // ignore: unawaited_futures
    _sendToBackend(subscription);
  }

  /// Send subscription update to backend
  ///
  /// TODO: Replace with actual API call
  Future<void> _sendToBackend(Subscription subscription) async {
    try {
      // Placeholder for backend sync
      // When backend is ready, call:
      // await dio.post('/user/subscription/sync', data: {
      //   'tier': subscription.tier.name,
      //   'status': subscription.status.name,
      //   'expires_at': subscription.expiresAt?.toIso8601String(),
      //   'product_id': subscription.productId,
      // });
    } catch (e) {
      // Silently fail - this is fire and forget
      // Backend sync will happen on next app restart
    }
  }
}
