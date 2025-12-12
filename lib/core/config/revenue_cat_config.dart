/// RevenueCat configuration for in-app purchases and subscriptions
///
/// This file contains configuration for RevenueCat SDK integration,
/// including API keys and product identifiers.
class RevenueCatConfig {
  RevenueCatConfig._();

  /// RevenueCat API key
  ///
  /// Get this from RevenueCat dashboard:
  /// https://app.revenuecat.com/projects/
  ///
  /// IMPORTANT: In production, use environment variables or secure config
  static const String apiKey = String.fromEnvironment(
    'REVENUE_CAT_API_KEY',
    defaultValue: 'YOUR_REVENUE_CAT_API_KEY_HERE',
  );

  // ==========================================================================
  // Product Identifiers
  // ==========================================================================

  /// Plus tier - Monthly subscription
  ///
  /// Configure in App Store Connect / Google Play Console
  static const String plusMonthlyId = 'apothy_plus_monthly';

  /// Plus tier - Yearly subscription
  ///
  /// Configure in App Store Connect / Google Play Console
  static const String plusYearlyId = 'apothy_plus_yearly';

  /// Pro tier - Monthly subscription
  ///
  /// Configure in App Store Connect / Google Play Console
  static const String proMonthlyId = 'apothy_pro_monthly';

  /// Pro tier - Yearly subscription
  ///
  /// Configure in App Store Connect / Google Play Console
  static const String proYearlyId = 'apothy_pro_yearly';

  /// All product IDs for RevenueCat configuration
  static const List<String> allProductIds = [
    plusMonthlyId,
    plusYearlyId,
    proMonthlyId,
    proYearlyId,
  ];

  // ==========================================================================
  // Entitlement Identifiers
  // ==========================================================================

  /// Plus entitlement identifier (configure in RevenueCat dashboard)
  static const String plusEntitlement = 'plus';

  /// Pro entitlement identifier (configure in RevenueCat dashboard)
  static const String proEntitlement = 'pro';

  // ==========================================================================
  // Configuration Helpers
  // ==========================================================================

  /// Check if RevenueCat is configured
  static bool get isConfigured =>
      apiKey != 'YOUR_REVENUE_CAT_API_KEY_HERE' && apiKey.isNotEmpty;

  /// Check if running in production mode
  static bool get isProduction =>
      const bool.fromEnvironment('dart.vm.product', defaultValue: false);
}
