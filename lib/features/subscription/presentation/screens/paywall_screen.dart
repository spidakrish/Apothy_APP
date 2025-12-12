import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/subscription.dart';
import '../providers/subscription_providers.dart';
import '../widgets/subscription_card.dart';

/// Paywall screen shown when user hits a subscription limit
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({
    super.key,
    this.feature,
  });

  /// Which feature triggered the paywall (for analytics/messaging)
  final String? feature;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  @override
  void initState() {
    super.initState();
    // Load offerings when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionProvider.notifier).loadOfferings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subscriptionState = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with close button
            _buildHeader(context),

            // Feature preview message
            _buildFeatureMessage(context, l10n),

            const SizedBox(height: 24),

            // Subscription options
            Expanded(
              child: subscriptionState.when(
                data: (state) {
                  if (state.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (state.offerings.isEmpty) {
                    return _buildNoOfferings(l10n);
                  }

                  return _buildOfferingsList(state.offerings);
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
                error: (error, _) => _buildError(l10n, error.toString()),
              ),
            ),

            // Footer with restore purchases and legal links
            _buildFooter(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // Spacer for centering
          Text(
            'Upgrade',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureMessage(BuildContext context, AppLocalizations l10n) {
    String message;
    IconData icon;

    switch (widget.feature) {
      case 'emotion_challenge_limit':
        message = l10n.subscriptionLimitMessage;
        icon = Icons.psychology;
        break;
      case 'chat_xp':
        message = 'Upgrade to earn XP from AI conversations';
        icon = Icons.stars;
        break;
      case 'achievements':
        message = 'Unlock all achievements with a premium subscription';
        icon = Icons.emoji_events;
        break;
      default:
        message = 'Unlock premium features with a subscription';
        icon = Icons.workspace_premium;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferingsList(List offerings) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        // Plus Monthly
        SubscriptionCard(
          tier: SubscriptionTier.plus,
          title: 'Plus',
          price: '\$9.99',
          period: 'per month',
          features: const [
            'Unlimited emotion challenges',
            'Full XP rewards',
            'Unlimited message history',
            'All achievements unlocked',
            'Cloud sync',
            'Advanced analytics',
          ],
          isPopular: true,
          onTap: () => _handlePurchase(offerings.first),
        ),

        const SizedBox(height: 16),

        // Plus Yearly
        SubscriptionCard(
          tier: SubscriptionTier.plus,
          title: 'Plus Yearly',
          price: '\$79.99',
          period: 'per year',
          features: const [
            'All Plus features',
            'Save 33% vs monthly',
          ],
          badge: 'Best Value',
          onTap: () => _handlePurchase(offerings.length > 1 ? offerings[1] : offerings.first),
        ),

        const SizedBox(height: 16),

        // Pro Yearly
        SubscriptionCard(
          tier: SubscriptionTier.pro,
          title: 'Pro',
          price: '\$159.99',
          period: 'per year',
          features: const [
            'Everything in Plus',
            'Priority AI responses',
            'Custom themes',
            'Therapist export',
            'Early access to features',
            'Premium support',
          ],
          badge: 'Premium',
          onTap: () => _handlePurchase(offerings.length > 2 ? offerings[2] : offerings.first),
        ),
      ],
    );
  }

  Widget _buildNoOfferings(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No subscriptions available',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              ref.read(subscriptionProvider.notifier).loadOfferings();
            },
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load subscriptions',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              ref.read(subscriptionProvider.notifier).loadOfferings();
            },
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Restore purchases button
          TextButton(
            onPressed: _handleRestorePurchases,
            child: Text(
              l10n.subscriptionRestorePurchases,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Legal links
          Text(
            'By subscribing, you agree to our Terms of Service and Privacy Policy',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase(dynamic package) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  'Processing purchase...',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final success = await ref
        .read(subscriptionProvider.notifier)
        .purchase(package);

    if (!mounted) return;

    // Close loading dialog
    Navigator.of(context).pop();

    if (success) {
      // Show success and close paywall
      _showSuccessDialog();
    } else {
      // Show error
      final failure = ref.read(subscriptionFailureProvider);
      _showErrorSnackBar(failure?.message ?? 'Purchase failed');
    }
  }

  Future<void> _handleRestorePurchases() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  'Restoring purchases...',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final success = await ref
        .read(subscriptionProvider.notifier)
        .restorePurchases();

    if (!mounted) return;

    // Close loading dialog
    Navigator.of(context).pop();

    if (success) {
      _showSuccessDialog();
    } else {
      _showErrorSnackBar('No purchases found to restore');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Success!',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Your subscription is now active',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              context.pop(); // Close paywall
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
