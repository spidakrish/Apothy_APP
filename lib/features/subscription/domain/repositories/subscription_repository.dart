import 'package:fpdart/fpdart.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/error/failures.dart';
import '../entities/subscription.dart';

/// Repository interface for subscription management
abstract class SubscriptionRepository {
  /// Initialize the repository and local storage
  Future<Either<Failure, void>> initialize();

  /// Get current subscription status
  ///
  /// Checks local cache first, then fetches from RevenueCat if expired
  /// Returns [Subscription.free()] if no active subscription
  Future<Either<Failure, Subscription>> getSubscription();

  /// Get available subscription offerings from RevenueCat
  ///
  /// Returns list of available packages (Plus Monthly, Plus Yearly, etc.)
  Future<Either<Failure, List<Package>>> getOfferings();

  /// Purchase a subscription package
  ///
  /// Handles the purchase flow, updates local cache, and syncs with backend
  Future<Either<Failure, Subscription>> purchasePackage(Package package);

  /// Restore previous purchases
  ///
  /// Useful when user reinstalls app or signs in on new device
  Future<Either<Failure, Subscription>> restorePurchases();

  /// Manually sync subscription status with backend
  ///
  /// Force a refresh from RevenueCat and update backend
  Future<Either<Failure, void>> syncWithBackend();

  /// Clear local subscription cache
  Future<Either<Failure, void>> clearCache();
}
