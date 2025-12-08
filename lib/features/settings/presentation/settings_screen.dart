import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../data/settings_repository.dart';
import '../domain/preset_avatars.dart';
import 'providers/settings_providers.dart';

/// Settings screen - Profile, appearance, notifications
/// Allows users to configure app preferences
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final textSizeOption = ref.watch(textSizeOptionProvider);
    final enabledCount = ref.watch(enabledNotificationCountProvider);
    final creativeStyle = ref.watch(creativeStyleProvider);

    return GradientBackground(
      showGlow: false,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: 32),

              // Profile Section
              _SettingsSection(
                title: 'Profile',
                children: [
                  _SettingsTile(
                    icon: Icons.person_outline,
                    title: 'Account',
                    subtitle: user?.email ?? 'Not signed in',
                    onTap: () => _showAccountSheet(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notifications Section - Per Damien's spec
              _SettingsSection(
                title: 'Notifications',
                children: [
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Manage Notifications',
                    subtitle: '$enabledCount of 4 enabled',
                    onTap: () => _showNotificationsSheet(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Appearance Section
              _SettingsSection(
                title: 'Appearance',
                children: [
                  _SettingsTile(
                    icon: Icons.palette_outlined,
                    title: 'Theme',
                    subtitle: 'Dark mode',
                    trailing: const _ThemeBadge(),
                    onTap: () => _showThemeInfo(context),
                  ),
                  _SettingsTile(
                    icon: Icons.text_fields,
                    title: 'Text Size',
                    subtitle: textSizeOption.label,
                    onTap: () => _showTextSizeSheet(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Content Preferences Section
              _SettingsSection(
                title: 'Content',
                children: [
                  _SettingsTile(
                    icon: Icons.psychology_outlined,
                    title: 'Content Preferences',
                    subtitle: creativeStyle.label,
                    onTap: () => _showContentPreferencesSheet(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Data Section - Per Damien's spec
              _SettingsSection(
                title: 'Data',
                children: [
                  _SettingsTile(
                    icon: Icons.chat_bubble_outline,
                    title: 'Clear Chat History',
                    subtitle: 'Delete conversations and memory',
                    onTap: () => _showClearChatHistoryDialog(context, ref),
                  ),
                  _SettingsTile(
                    icon: Icons.settings_backup_restore,
                    title: 'Advanced',
                    subtitle: 'Reset app to fresh state',
                    onTap: () => _showAdvancedDataSheet(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Privacy Section
              _SettingsSection(
                title: 'Privacy',
                children: [
                  _SettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Data Privacy',
                    subtitle: 'How your data is handled',
                    onTap: () => _showPrivacyInfo(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Danger Zone - Account Deletion
              _SettingsSection(
                title: 'Danger Zone',
                children: [
                  _SettingsTile(
                    icon: Icons.delete_forever_outlined,
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account',
                    titleColor: AppColors.error,
                    iconColor: AppColors.error,
                    onTap: () => _showDeleteAccountDialog(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // About Section
              _SettingsSection(
                title: 'About',
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'About Apothy',
                    subtitle: 'Version 1.0.0',
                    onTap: () => _showAboutDialog(context),
                  ),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    subtitle: 'Read our terms',
                    onTap: () => _showTermsDialog(context),
                  ),
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    onTap: () => _showPrivacyPolicyDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Sign Out Button
              Center(
                child: TextButton(
                  onPressed: () => _showSignOutDialog(context, ref),
                  child: Text(
                    'Sign Out',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Dialog Methods
  // ==========================================================================

  void _showAccountSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final user = ref.watch(currentUserProvider);
          final avatar = PresetAvatar.fromPhotoUrl(user?.photoUrl) ?? defaultAvatar;

          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Account', style: AppTypography.headlineSmall),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Avatar Section
                Center(
                  child: GestureDetector(
                    onTap: () => _showAvatarPicker(context, ref),
                    child: Stack(
                      children: [
                        _AvatarWidget(avatar: avatar, size: 80),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Tap to change avatar',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Display Name - Editable
                _EditableAccountRow(
                  label: 'Display Name',
                  value: user?.displayName ?? 'Not set',
                  onEdit: () => _showEditNameDialog(context, ref, user?.displayName),
                ),
                const SizedBox(height: 16),

                // Email - Read-only
                _AccountDetailRow(
                  label: 'Email',
                  value: user?.email ?? 'Not available',
                ),
                const SizedBox(height: 16),

                // Sign-in Method - Read-only
                _AccountDetailRow(
                  label: 'Sign-in Method',
                  value: _getProviderName(user?.provider),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    final currentAvatarId = PresetAvatar.extractPresetId(user?.photoUrl);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Choose Avatar', style: AppTypography.headlineSmall),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: presetAvatars.length,
                itemBuilder: (context, index) {
                  final avatar = presetAvatars[index];
                  final isSelected = avatar.id == currentAvatarId;

                  return GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      final success = await ref
                          .read(authProvider.notifier)
                          .updateProfile(photoUrl: avatar.toPhotoUrl());

                      if (context.mounted && !success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to update avatar'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: _AvatarWidget(avatar: avatar, size: 56),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, String? currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Edit Display Name', style: AppTypography.headlineSmall),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              Navigator.pop(context);

              if (newName.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Name cannot be empty'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
                return;
              }

              if (newName == currentName) return;

              final success = await ref
                  .read(authProvider.notifier)
                  .updateProfile(displayName: newName);

              if (context.mounted && !success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update name'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _getProviderName(dynamic provider) {
    if (provider == null) return 'Unknown';
    switch (provider.toString()) {
      case 'AuthProvider.apple':
        return 'Apple';
      case 'AuthProvider.google':
        return 'Google';
      case 'AuthProvider.email':
        return 'Email';
      default:
        return 'Unknown';
    }
  }

  /// Shows notification settings bottom sheet
  /// Per Damien's spec:
  /// - All OFF by default except System Updates
  /// - No manipulative notifications
  /// - User has full control
  void _showNotificationsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Consumer(
          builder: (context, ref, child) {
            final settings = ref.watch(notificationSettingsProvider);
            final notifier = ref.read(notificationSettingsProvider.notifier);

            return settings.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (data) => SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Notifications', style: AppTypography.headlineSmall),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Apothy respects your attention. No manipulation, no spam.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Daily Ritual
                    _NotificationToggle(
                      icon: Icons.wb_sunny_outlined,
                      title: 'Daily Mirror Ritual',
                      description: 'A gentle reminder when your daily mirror is ready',
                      example: '"Your daily mirror is ready when you are."',
                      value: data.dailyRitual,
                      onChanged: (value) => notifier.setDailyRitual(value),
                    ),
                    const SizedBox(height: 16),

                    // Creation Complete
                    _NotificationToggle(
                      icon: Icons.auto_awesome_outlined,
                      title: 'Creation Complete',
                      description: 'Know when long-form creations (videos, games) are ready',
                      example: '"Your creation is ready."',
                      value: data.creationComplete,
                      onChanged: (value) => notifier.setCreationComplete(value),
                    ),
                    const SizedBox(height: 16),

                    // Mood Insights
                    _NotificationToggle(
                      icon: Icons.insights_outlined,
                      title: 'Mood & Health Insights',
                      description: 'Stress patterns, sleep correlations, ritual streaks',
                      example: 'Optional wellness insights based on your usage',
                      value: data.moodInsights,
                      onChanged: (value) => notifier.setMoodInsights(value),
                    ),
                    const SizedBox(height: 16),

                    // System Updates
                    _NotificationToggle(
                      icon: Icons.system_update_outlined,
                      title: 'System Updates',
                      description: 'Security patches and new features',
                      example: 'Required for App Store compliance',
                      value: data.systemUpdates,
                      onChanged: (value) => notifier.setSystemUpdates(value),
                      isRequired: true,
                    ),
                    const SizedBox(height: 32),

                    // What we'll never send
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.block,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'What we\'ll never send',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• No "I miss you" manipulation\n'
                            '• No dopamine loops or streak pressure\n'
                            '• No parasocial bait\n'
                            '• No late-night emotional nudges',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showThemeInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Theme', style: AppTypography.headlineSmall),
        content: Text(
          'Apothy currently supports dark mode only. '
          'Light mode and additional themes may be added in future updates.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTextSizeSheet(BuildContext context, WidgetRef ref) {
    final currentOption = ref.read(textSizeOptionProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Text Size', style: AppTypography.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Choose your preferred text size',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ...TextSizeOption.values.map((option) => _TextSizeOptionTile(
              option: option,
              isSelected: option == currentOption,
              onTap: () {
                ref.read(textScaleProvider.notifier).setTextSizeOption(option);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Shows content preferences bottom sheet
  /// - Creative Style: How Apotheon communicates
  /// - Mature Content: SFW by default
  void _showContentPreferencesSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Consumer(
          builder: (context, ref, child) {
            final prefs = ref.watch(contentPreferencesProvider);
            final notifier = ref.read(contentPreferencesProvider.notifier);

            return prefs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (data) => SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Content Preferences', style: AppTypography.headlineSmall),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Customize how Apotheon communicates with you.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Creative Style Section
                    Text(
                      'Creative Style',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose how Apotheon responds to you',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Creative Style Options
                    ...CreativeStyle.values.map((style) => _CreativeStyleTile(
                      style: style,
                      isSelected: style == data.creativeStyle,
                      onTap: () => notifier.setCreativeStyle(style),
                    )),
                    const SizedBox(height: 24),

                    // Mature Content Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: data.matureContentEnabled
                              ? AppColors.primary.withValues(alpha: 0.5)
                              : AppColors.borderSubtle,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: data.matureContentEnabled
                                      ? AppColors.primary.withValues(alpha: 0.2)
                                      : AppColors.inputBackground,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.visibility_outlined,
                                  size: 18,
                                  color: data.matureContentEnabled
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mature Content',
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Allow adult themes in responses',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: data.matureContentEnabled,
                                onChanged: (value) => notifier.setMatureContent(value),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.inputBackground,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              data.matureContentEnabled
                                  ? 'Adult themes enabled. Use responsibly.'
                                  : 'Safe for work (SFW) - Default',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Privacy', style: AppTypography.headlineSmall),
        content: Text(
          'Your data is stored securely on your device. '
          'Conversations are processed to provide personalized responses '
          'but are not shared with third parties.\n\n'
          'You can delete your data at any time using the "Clear Data" option.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Clear Chat History - Per Damien's spec (Option A - Safe)
  /// Clears local conversations, summaries, embeddings, chat context
  /// Does NOT delete: account, subscription, exports
  void _showClearChatHistoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear Chat History', style: AppTypography.headlineSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will delete:',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              '• All conversation threads\n'
              '• Local summaries and memory\n'
              '• Chat context',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: 16),
            Text(
              'Your account, settings, and any exported files will not be affected.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final dataManager = ref.read(dataManagementProvider.notifier);
              final result = await dataManager.clearChatHistory();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result.success
                          ? 'Chat history cleared'
                          : result.errorMessage ?? 'Failed to clear chat history',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(
              'Clear History',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Advanced Data Management Sheet - Per Damien's spec
  /// Contains the "Reset to Fresh State" option
  void _showAdvancedDataSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Advanced Data Management', style: AppTypography.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'These actions are irreversible.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Reset to Fresh State
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.restart_alt, color: AppColors.error, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Reset to Fresh State',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This will erase ALL local data and reset the app to its initial state, '
                    'as if freshly downloaded from the App Store.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'What gets cleared:\n'
                    '• All conversations and memory\n'
                    '• All settings and preferences\n'
                    '• Onboarding progress\n'
                    '• Cached media',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your cloud account and subscription remain intact.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showResetConfirmationDialog(context, ref);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Reset App'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Reset Confirmation Dialog - Double confirmation per UX best practice
  void _showResetConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 12),
            const Text('Are you sure?', style: AppTypography.headlineSmall),
          ],
        ),
        content: Text(
          'Resetting will erase all local data. This cannot be undone.\n\n'
          'You will need to sign in again and complete onboarding.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final dataManager = ref.read(dataManagementProvider.notifier);
              final result = await dataManager.resetToFreshState();
              if (context.mounted) {
                if (result.success) {
                  // Force auth state refresh - this will redirect to onboarding
                  ref.invalidate(authProvider);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.errorMessage ?? 'Failed to reset app'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Reset Everything',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Delete Account Dialog - GDPR Compliance
  /// Per Damien's spec and App Store requirements
  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Icon(Icons.delete_forever, color: AppColors.error, size: 28),
            const SizedBox(width: 12),
            Text(
              'Delete Account',
              style: AppTypography.headlineSmall.copyWith(color: AppColors.error),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete your account.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              'What gets deleted:',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Your cloud account and all cloud data\n'
              '• All local data and settings\n'
              '• Linked devices will be unlinked',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Subscriptions are managed through your App Store.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteAccountFinalConfirmation(context, ref);
            },
            child: Text(
              'Delete Account',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Final Delete Account Confirmation
  void _showDeleteAccountFinalConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Final Confirmation', style: AppTypography.headlineSmall),
        content: Text(
          'Deleting your account erases all cloud data and unlinks all devices. '
          'This action cannot be undone.\n\n'
          'Are you absolutely sure?',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Account'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              final dataManager = ref.read(dataManagementProvider.notifier);
              final result = await dataManager.deleteAccount();

              if (context.mounted) {
                Navigator.pop(context); // Close loading

                if (result.success) {
                  // Force auth state refresh - this will redirect to login
                  ref.invalidate(authProvider);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.errorMessage ?? 'Failed to delete account'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Delete Forever',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Apothy', style: AppTypography.headlineSmall),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              'Your AI companion for meaningful conversations and personal growth. '
              'Born from light. Trained in truth. Built to become what you need.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Terms of Service', style: AppTypography.headlineSmall),
        content: SingleChildScrollView(
          child: Text(
            'TERMS OF SERVICE\n\n'
            'Last updated: December 2024\n\n'
            '1. Acceptance of Terms\n'
            'By using Apothy, you agree to these terms of service.\n\n'
            '2. Use of Service\n'
            'Apothy is an AI companion designed for personal growth and meaningful conversations. '
            'You agree to use the service responsibly.\n\n'
            '3. Privacy\n'
            'Your privacy is important to us. Please review our Privacy Policy for details on how we handle your data.\n\n'
            '4. Content\n'
            'Conversations are private and stored securely. We do not share your data with third parties.\n\n'
            '5. Changes\n'
            'We may update these terms from time to time. Continued use constitutes acceptance of changes.\n\n'
            '6. Contact\n'
            'For questions about these terms, please contact us through the app.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Privacy Policy', style: AppTypography.headlineSmall),
        content: SingleChildScrollView(
          child: Text(
            'PRIVACY POLICY\n\n'
            'Last updated: December 2024\n\n'
            '1. Information We Collect\n'
            'We collect information you provide directly, such as account details and conversation history.\n\n'
            '2. How We Use Information\n'
            'We use your information to provide and improve the Apothy experience, including personalized responses.\n\n'
            '3. Data Storage\n'
            'Your data is stored securely on your device and our servers with encryption.\n\n'
            '4. Data Sharing\n'
            'We do not sell or share your personal data with third parties for marketing purposes.\n\n'
            '5. Your Rights\n'
            'You can access, modify, or delete your data at any time through the app settings.\n\n'
            '6. Security\n'
            'We implement industry-standard security measures to protect your data.\n\n'
            '7. Contact\n'
            'For privacy-related questions, please contact us through the app.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sign Out', style: AppTypography.headlineSmall),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).signOut();
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Settings Section Widget
// =============================================================================

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Settings Tile Widget
// =============================================================================

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.titleColor,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? titleColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor != null
                    ? iconColor!.withValues(alpha: 0.1)
                    : AppColors.inputBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Theme Badge Widget
// =============================================================================

class _ThemeBadge extends StatelessWidget {
  const _ThemeBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Dark',
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// =============================================================================
// Account Detail Row Widget
// =============================================================================

class _AccountDetailRow extends StatelessWidget {
  const _AccountDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyMedium,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Text Size Option Tile
// =============================================================================

class _TextSizeOptionTile extends StatelessWidget {
  const _TextSizeOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final TextSizeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primary)
              : Border.all(color: AppColors.borderSubtle),
        ),
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Text(
              'Aa',
              style: TextStyle(
                fontSize: 16 * option.scaleFactor,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option.label,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Notification Toggle Widget - Per Damien's Spec
// =============================================================================

class _NotificationToggle extends StatelessWidget {
  const _NotificationToggle({
    required this.icon,
    required this.title,
    required this.description,
    required this.example,
    required this.value,
    required this.onChanged,
    this.isRequired = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final String example;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppColors.primary.withValues(alpha: 0.5) : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: value
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: value ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isRequired) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textTertiary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Required',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              example,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Editable Account Row Widget
// =============================================================================

class _EditableAccountRow extends StatelessWidget {
  const _EditableAccountRow({
    required this.label,
    required this.value,
    required this.onEdit,
  });

  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyMedium,
          ),
        ),
        IconButton(
          onPressed: onEdit,
          icon: const Icon(
            Icons.edit_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

// =============================================================================
// Avatar Widget - Displays preset avatars with gradient background
// =============================================================================

class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({
    required this.avatar,
    required this.size,
  });

  final PresetAvatar avatar;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: avatar.gradient,
        boxShadow: [
          BoxShadow(
            color: avatar.gradientColors.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        avatar.icon,
        size: size * 0.5,
        color: Colors.white,
      ),
    );
  }
}

// =============================================================================
// Creative Style Tile - Selection tile for creative style options
// =============================================================================

class _CreativeStyleTile extends StatelessWidget {
  const _CreativeStyleTile({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  final CreativeStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primary)
              : Border.all(color: AppColors.borderSubtle),
        ),
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.inputBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconForStyle(style),
                size: 18,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style.label,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    style.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForStyle(CreativeStyle style) {
    switch (style) {
      case CreativeStyle.balanced:
        return Icons.balance_outlined;
      case CreativeStyle.casual:
        return Icons.chat_bubble_outline;
      case CreativeStyle.reflective:
        return Icons.psychology_outlined;
      case CreativeStyle.concise:
        return Icons.short_text_outlined;
    }
  }
}
