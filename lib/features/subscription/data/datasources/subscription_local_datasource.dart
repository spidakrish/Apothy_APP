import 'package:hive_flutter/hive_flutter.dart';

import '../models/subscription_model.dart';

/// Local datasource for subscription data persistence using Hive
abstract class SubscriptionLocalDatasource {
  /// Initialize Hive box for subscriptions
  Future<void> initialize();

  /// Get cached subscription
  Future<SubscriptionModel?> getSubscription();

  /// Save subscription to local cache
  Future<void> saveSubscription(SubscriptionModel subscription);

  /// Clear subscription cache
  Future<void> clearSubscription();

  /// Check if adapter is registered
  bool get isAdapterRegistered;
}

/// Implementation of SubscriptionLocalDatasource using Hive
class SubscriptionLocalDatasourceImpl implements SubscriptionLocalDatasource {
  /// Hive box for storing subscription
  Box<SubscriptionModel>? _subscriptionBox;

  /// Box name constant
  static const String _boxName = 'subscription';

  /// Key for storing current subscription
  static const String _currentSubKey = 'current';

  @override
  bool get isAdapterRegistered => Hive.isAdapterRegistered(
        SubscriptionHiveTypeIds.subscriptionModel,
      );

  @override
  Future<void> initialize() async {
    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(
      SubscriptionHiveTypeIds.subscriptionTierAdapter,
    )) {
      Hive.registerAdapter(SubscriptionTierHiveAdapter());
    }

    if (!Hive.isAdapterRegistered(
      SubscriptionHiveTypeIds.subscriptionStatusAdapter,
    )) {
      Hive.registerAdapter(SubscriptionStatusHiveAdapter());
    }

    if (!Hive.isAdapterRegistered(
      SubscriptionHiveTypeIds.subscriptionModel,
    )) {
      Hive.registerAdapter(SubscriptionModelAdapter());
    }

    // Open box if not already open
    if (!Hive.isBoxOpen(_boxName)) {
      _subscriptionBox = await Hive.openBox<SubscriptionModel>(_boxName);
    } else {
      _subscriptionBox = Hive.box<SubscriptionModel>(_boxName);
    }
  }

  @override
  Future<SubscriptionModel?> getSubscription() async {
    _ensureInitialized();
    return _subscriptionBox!.get(_currentSubKey);
  }

  @override
  Future<void> saveSubscription(SubscriptionModel subscription) async {
    _ensureInitialized();
    await _subscriptionBox!.put(_currentSubKey, subscription);
  }

  @override
  Future<void> clearSubscription() async {
    _ensureInitialized();
    await _subscriptionBox!.delete(_currentSubKey);
  }

  /// Ensure box is initialized before operations
  void _ensureInitialized() {
    if (_subscriptionBox == null || !_subscriptionBox!.isOpen) {
      throw StateError(
        'SubscriptionLocalDatasource not initialized. Call initialize() first.',
      );
    }
  }
}
