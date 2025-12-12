import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/subscription_local_datasource.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';

// =============================================================================
// Datasource Provider
// =============================================================================

/// Provider for subscription local datasource
final subscriptionLocalDatasourceProvider =
    Provider<SubscriptionLocalDatasource>((ref) {
  return SubscriptionLocalDatasourceImpl();
});

// =============================================================================
// Repository Provider
// =============================================================================

/// Provider for subscription repository
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final localDatasource = ref.watch(subscriptionLocalDatasourceProvider);
  return SubscriptionRepositoryImpl(localDatasource: localDatasource);
});

// =============================================================================
// State Classes
// =============================================================================

/// State for subscription data
class SubscriptionState {
  const SubscriptionState({
    required this.subscription,
    this.isLoading = false,
    this.failure,
    this.offerings = const [],
  });

  /// Factory for initial state
  factory SubscriptionState.initial() => SubscriptionState(
        subscription: Subscription.free(),
      );

  /// Current subscription
  final Subscription subscription;

  /// Loading state (for purchase operations)
  final bool isLoading;

  /// Error/failure state
  final Failure? failure;

  /// Available subscription packages
  final List<Package> offerings;

  /// Create a copy with updated fields
  SubscriptionState copyWith({
    Subscription? subscription,
    bool? isLoading,
    Failure? failure,
    List<Package>? offerings,
  }) {
    return SubscriptionState(
      subscription: subscription ?? this.subscription,
      isLoading: isLoading ?? this.isLoading,
      failure: failure,
      offerings: offerings ?? this.offerings,
    );
  }
}

// =============================================================================
// Subscription Notifier
// =============================================================================

/// Notifier for managing subscription state
class SubscriptionNotifier extends AsyncNotifier<SubscriptionState> {
  late SubscriptionRepository _repository;

  @override
  Future<SubscriptionState> build() async {
    _repository = ref.read(subscriptionRepositoryProvider);

    // Initialize repository
    final initResult = await _repository.initialize();
    await initResult.fold(
      (failure) async {
        // Log error but continue with default state
        return SubscriptionState.initial().copyWith(failure: failure);
      },
      (_) async {},
    );

    // Load subscription
    return _loadSubscription();
  }

  /// Load subscription from repository
  Future<SubscriptionState> _loadSubscription() async {
    final result = await _repository.getSubscription();

    return result.fold(
      (failure) => SubscriptionState.initial().copyWith(failure: failure),
      (subscription) => SubscriptionState(subscription: subscription),
    );
  }

  /// Refresh subscription status
  Future<void> refresh() async {
    state = AsyncValue.data(state.value!.copyWith(isLoading: true));

    final result = await _repository.getSubscription();

    result.fold(
      (failure) {
        state = AsyncValue.data(
          state.value!.copyWith(isLoading: false, failure: failure),
        );
      },
      (subscription) {
        state = AsyncValue.data(
          SubscriptionState(subscription: subscription),
        );
      },
    );
  }

  /// Load available offerings
  Future<void> loadOfferings() async {
    state = AsyncValue.data(state.value!.copyWith(isLoading: true));

    final result = await _repository.getOfferings();

    result.fold(
      (failure) {
        state = AsyncValue.data(
          state.value!.copyWith(isLoading: false, failure: failure),
        );
      },
      (offerings) {
        state = AsyncValue.data(
          state.value!.copyWith(
            isLoading: false,
            offerings: offerings,
          ),
        );
      },
    );
  }

  /// Purchase a subscription package
  Future<bool> purchase(Package package) async {
    state = AsyncValue.data(state.value!.copyWith(isLoading: true));

    final result = await _repository.purchasePackage(package);

    return result.fold(
      (failure) {
        state = AsyncValue.data(
          state.value!.copyWith(isLoading: false, failure: failure),
        );
        return false;
      },
      (subscription) {
        state = AsyncValue.data(
          SubscriptionState(subscription: subscription),
        );
        return true;
      },
    );
  }

  /// Restore previous purchases
  Future<bool> restorePurchases() async {
    state = AsyncValue.data(state.value!.copyWith(isLoading: true));

    final result = await _repository.restorePurchases();

    return result.fold(
      (failure) {
        state = AsyncValue.data(
          state.value!.copyWith(isLoading: false, failure: failure),
        );
        return false;
      },
      (subscription) {
        state = AsyncValue.data(
          SubscriptionState(subscription: subscription),
        );
        return true;
      },
    );
  }

  /// Manually sync with backend
  Future<void> syncWithBackend() async {
    await _repository.syncWithBackend();
  }

  /// Clear any error state
  void clearError() {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(failure: null));
    }
  }
}

// =============================================================================
// Main Subscription Provider
// =============================================================================

/// Main provider for subscription state
final subscriptionProvider =
    AsyncNotifierProvider<SubscriptionNotifier, SubscriptionState>(
  SubscriptionNotifier.new,
);

// =============================================================================
// Convenience Providers
// =============================================================================

/// Provider for current subscription tier
final subscriptionTierProvider = Provider<SubscriptionTier>((ref) {
  return ref.watch(subscriptionProvider).maybeWhen(
        data: (state) => state.subscription.tier,
        orElse: () => SubscriptionTier.free,
      );
});

/// Provider for whether user has premium access
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).maybeWhen(
        data: (state) => state.subscription.isPremium,
        orElse: () => false,
      );
});

/// Provider for whether user has pro access
final isProProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).maybeWhen(
        data: (state) => state.subscription.isPro,
        orElse: () => false,
      );
});

/// Provider for subscription status
final subscriptionStatusProvider = Provider<SubscriptionStatus>((ref) {
  return ref.watch(subscriptionProvider).maybeWhen(
        data: (state) => state.subscription.status,
        orElse: () => SubscriptionStatus.active,
      );
});

/// Provider for whether subscription is active
final isSubscriptionActiveProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).maybeWhen(
        data: (state) => state.subscription.isActive,
        orElse: () => true,
      );
});

/// Provider for days until expiration
final daysUntilExpirationProvider = Provider<int?>((ref) {
  return ref.watch(subscriptionProvider).maybeWhen(
        data: (state) => state.subscription.daysUntilExpiration,
        orElse: () => null,
      );
});

/// Provider for whether subscription is in final days
final isInFinalDaysProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).maybeWhen(
        data: (state) => state.subscription.isInFinalDays,
        orElse: () => false,
      );
});

/// Provider for available subscription offerings
final offeringsProvider = Provider<List<Package>>((ref) {
  return ref.watch(subscriptionProvider).maybeWhen(
        data: (state) => state.offerings,
        orElse: () => [],
      );
});

/// Provider for loading state
final subscriptionLoadingProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).maybeWhen(
        data: (state) => state.isLoading,
        orElse: () => false,
      );
});

/// Provider for failure state
final subscriptionFailureProvider = Provider<Failure?>((ref) {
  return ref.watch(subscriptionProvider).maybeWhen(
        data: (state) => state.failure,
        orElse: () => null,
      );
});
