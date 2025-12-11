import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/local_notification_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../data/settings_repository.dart';

// =============================================================================
// SharedPreferences Provider
// =============================================================================

/// Provider for SharedPreferences instance
/// Must be overridden in main.dart with the actual instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main.dart');
});

// =============================================================================
// Repository Provider
// =============================================================================

/// Provider for SettingsRepository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepositoryImpl(preferences: prefs);
});

// =============================================================================
// Text Scale Provider
// =============================================================================

/// Notifier for managing text scale factor
class TextScaleNotifier extends AsyncNotifier<double> {
  late SettingsRepository _repository;

  @override
  Future<double> build() async {
    _repository = ref.watch(settingsRepositoryProvider);
    return _repository.getTextScaleFactor();
  }

  /// Set text scale factor
  Future<void> setTextScale(double factor) async {
    state = const AsyncValue.loading();
    await _repository.setTextScaleFactor(factor);
    state = AsyncValue.data(factor);
  }

  /// Set text scale from option
  Future<void> setTextSizeOption(TextSizeOption option) async {
    await setTextScale(option.scaleFactor);
  }
}

/// Provider for text scale factor
final textScaleProvider = AsyncNotifierProvider<TextScaleNotifier, double>(
  TextScaleNotifier.new,
);

/// Convenience provider for current text size option
final textSizeOptionProvider = Provider<TextSizeOption>((ref) {
  final scaleFactor = ref.watch(textScaleProvider).valueOrNull ?? 1.0;
  return TextSizeOption.fromScaleFactor(scaleFactor);
});

// =============================================================================
// Notification Settings Provider
// =============================================================================

/// Notifier for managing all notification settings
/// Based on Damien's spec:
/// - Daily Ritual: OFF by default
/// - Creation Complete: OFF by default
/// - Mood Insights: OFF by default
/// - System Updates: ON by default (required by App Store)
class NotificationSettingsNotifier extends AsyncNotifier<NotificationSettings> {
  late SettingsRepository _repository;

  @override
  Future<NotificationSettings> build() async {
    _repository = ref.watch(settingsRepositoryProvider);
    return _repository.getNotificationSettings();
  }

  /// Toggle Daily Ritual notifications
  /// "Your daily mirror is ready when you are."
  Future<void> setDailyRitual(bool enabled) async {
    final current = state.valueOrNull ?? const NotificationSettings();
    state = const AsyncValue.loading();
    await _repository.setDailyRitualEnabled(enabled);
    state = AsyncValue.data(current.copyWith(dailyRitual: enabled));
  }

  /// Toggle Creation Complete notifications
  /// "Your creation is ready."
  Future<void> setCreationComplete(bool enabled) async {
    final current = state.valueOrNull ?? const NotificationSettings();
    state = const AsyncValue.loading();
    await _repository.setCreationCompleteEnabled(enabled);
    state = AsyncValue.data(current.copyWith(creationComplete: enabled));
  }

  /// Toggle Mood/Health Insights notifications
  /// Stress patterns, sleep correlations, ritual streaks
  Future<void> setMoodInsights(bool enabled) async {
    final current = state.valueOrNull ?? const NotificationSettings();
    state = const AsyncValue.loading();
    await _repository.setMoodInsightsEnabled(enabled);
    state = AsyncValue.data(current.copyWith(moodInsights: enabled));
  }

  /// Toggle System Updates notifications
  /// Security patches, new features (required by App Store)
  Future<void> setSystemUpdates(bool enabled) async {
    final current = state.valueOrNull ?? const NotificationSettings();
    state = const AsyncValue.loading();
    await _repository.setSystemUpdatesEnabled(enabled);
    state = AsyncValue.data(current.copyWith(systemUpdates: enabled));
  }

  /// Enable all notifications
  Future<void> enableAll() async {
    state = const AsyncValue.loading();
    await Future.wait([
      _repository.setDailyRitualEnabled(true),
      _repository.setCreationCompleteEnabled(true),
      _repository.setMoodInsightsEnabled(true),
      _repository.setSystemUpdatesEnabled(true),
    ]);
    state = AsyncValue.data(const NotificationSettings(
      dailyRitual: true,
      creationComplete: true,
      moodInsights: true,
      systemUpdates: true,
    ));
  }

  /// Disable all notifications (except system updates per spec)
  Future<void> disableAll() async {
    state = const AsyncValue.loading();
    await Future.wait([
      _repository.setDailyRitualEnabled(false),
      _repository.setCreationCompleteEnabled(false),
      _repository.setMoodInsightsEnabled(false),
      // Keep system updates ON as it's required
      _repository.setSystemUpdatesEnabled(true),
    ]);
    state = AsyncValue.data(const NotificationSettings(
      dailyRitual: false,
      creationComplete: false,
      moodInsights: false,
      systemUpdates: true,
    ));
  }
}

/// Provider for notification settings
final notificationSettingsProvider =
    AsyncNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  NotificationSettingsNotifier.new,
);

// =============================================================================
// Convenience Providers for Individual Notification Settings
// =============================================================================

/// Provider for daily ritual notification status
final dailyRitualEnabledProvider = Provider<bool>((ref) {
  return ref.watch(notificationSettingsProvider).valueOrNull?.dailyRitual ?? false;
});

/// Provider for creation complete notification status
final creationCompleteEnabledProvider = Provider<bool>((ref) {
  return ref.watch(notificationSettingsProvider).valueOrNull?.creationComplete ?? false;
});

/// Provider for mood insights notification status
final moodInsightsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(notificationSettingsProvider).valueOrNull?.moodInsights ?? false;
});

/// Provider for system updates notification status
final systemUpdatesEnabledProvider = Provider<bool>((ref) {
  return ref.watch(notificationSettingsProvider).valueOrNull?.systemUpdates ?? true;
});

/// Provider for count of enabled notifications
final enabledNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationSettingsProvider).valueOrNull?.enabledCount ?? 1;
});

// =============================================================================
// Data Management Providers
// Per Damien's spec:
// - Clear Chat History: local conversations, summaries, embeddings, context
// - Reset to Fresh State: full local purge including onboarding
// =============================================================================

/// Result of a data clearing operation
class DataClearingResult {
  const DataClearingResult({
    required this.success,
    this.errorMessage,
  });

  final bool success;
  final String? errorMessage;

  factory DataClearingResult.success() => const DataClearingResult(success: true);
  factory DataClearingResult.error(String message) =>
      DataClearingResult(success: false, errorMessage: message);
}

/// Notifier for managing data clearing operations
/// Per Damien's spec, provides two options:
/// A. "Clear Chat History" - Safe, everyday reset
/// B. "Reset to Fresh State" - Deep reset to App Store fresh install
class DataManagementNotifier extends Notifier<void> {
  late SettingsRepository _settingsRepository;

  @override
  void build() {
    _settingsRepository = ref.watch(settingsRepositoryProvider);
  }

  /// Clear Chat History (Option A - Safe)
  /// Per Damien's spec, this clears:
  /// - Local conversation threads
  /// - Local summaries
  /// - Embeddings tied to chat
  /// - Chat context
  /// - Lightweight memory
  ///
  /// Does NOT delete:
  /// - User account
  /// - Subscription tier
  /// - Purchased features
  /// - Export files saved externally
  Future<DataClearingResult> clearChatHistory() async {
    try {
      // TODO: Clear chat data when chat feature is implemented
      // - await chatRepository.clearAllConversations();
      // - await chatRepository.clearSummaries();
      // - await embeddingsRepository.clearChatEmbeddings();
      // - await memoryRepository.clearLightweightMemory();

      // For now, this is a stub that succeeds
      // Chat storage doesn't exist yet
      return DataClearingResult.success();
    } catch (e) {
      return DataClearingResult.error('Failed to clear chat history: $e');
    }
  }

  /// Reset App to Fresh State (Option B - Deep Reset)
  /// Per Damien's spec, this performs a full purge:
  /// - Clear chat
  /// - Clear identity core
  /// - Clear preference vectors
  /// - Clear embeddings
  /// - Clear all local data
  /// - Clear cached media
  /// - Clear local offline model
  /// - Reset onboarding
  /// - Reset rituals
  /// - Reset notifications
  /// - Reset ALL settings to defaults
  /// - Reset to App Store fresh install state
  ///
  /// Does NOT:
  /// - Cancel subscription (handled by App Store)
  /// - Delete cloud account
  Future<DataClearingResult> resetToFreshState() async {
    try {
      final authRepository = ref.read(authRepositoryProvider);

      // 1. Clear all chat data (when implemented)
      await clearChatHistory();

      // 2. Clear all settings (notifications, text size, etc.)
      await _settingsRepository.clearAllSettings();

      // 3. Clear all auth data INCLUDING onboarding status
      // This triggers the full local purge
      final result = await authRepository.clearAllLocalData();

      return result.fold(
        (failure) => DataClearingResult.error(failure.message),
        (_) => DataClearingResult.success(),
      );
    } catch (e) {
      return DataClearingResult.error('Failed to reset app: $e');
    }
  }

  /// Delete Account (GDPR Compliance)
  /// Per Damien's spec and App Store requirements:
  /// - Deletes cloud account
  /// - Deletes cloud-stored memory
  /// - Deletes sync keys
  /// - Unlinks all devices
  /// - Terminates subscription (handled by platform store)
  /// - Performs local deep reset
  ///
  /// Does NOT delete:
  /// - Purchased exports stored on user device
  /// - App Store purchase history (Apple controls this)
  Future<DataClearingResult> deleteAccount() async {
    try {
      final authRepository = ref.read(authRepositoryProvider);

      // 1. First clear all local data (chat, settings)
      await clearChatHistory();
      await _settingsRepository.clearAllSettings();

      // 2. Delete cloud account and clear all local auth data
      final result = await authRepository.deleteAccount();

      return result.fold(
        (failure) => DataClearingResult.error(failure.message),
        (_) => DataClearingResult.success(),
      );
    } catch (e) {
      return DataClearingResult.error('Failed to delete account: $e');
    }
  }
}

/// Provider for data management operations
final dataManagementProvider = NotifierProvider<DataManagementNotifier, void>(
  DataManagementNotifier.new,
);

// =============================================================================
// Content Preferences Provider
// =============================================================================

/// Notifier for managing content preferences
/// - Creative Style: How Apotheon communicates (Balanced, Casual, Reflective, Concise)
/// - Mature Content: SFW by default for App Store compliance
class ContentPreferencesNotifier extends AsyncNotifier<ContentPreferences> {
  late SettingsRepository _repository;

  @override
  Future<ContentPreferences> build() async {
    _repository = ref.watch(settingsRepositoryProvider);
    return _repository.getContentPreferences();
  }

  /// Set the creative style for AI responses
  Future<void> setCreativeStyle(CreativeStyle style) async {
    final current = state.valueOrNull ?? const ContentPreferences();
    state = const AsyncValue.loading();
    await _repository.setCreativeStyle(style);
    state = AsyncValue.data(current.copyWith(creativeStyle: style));
  }

  /// Set mature content enabled/disabled
  /// Default: false (SFW) for App Store compliance
  Future<void> setMatureContent(bool enabled) async {
    final current = state.valueOrNull ?? const ContentPreferences();
    state = const AsyncValue.loading();
    await _repository.setMatureContentEnabled(enabled);
    state = AsyncValue.data(current.copyWith(matureContentEnabled: enabled));
  }
}

/// Provider for content preferences
final contentPreferencesProvider =
    AsyncNotifierProvider<ContentPreferencesNotifier, ContentPreferences>(
  ContentPreferencesNotifier.new,
);

// =============================================================================
// Convenience Providers for Content Preferences
// =============================================================================

/// Provider for current creative style
final creativeStyleProvider = Provider<CreativeStyle>((ref) {
  return ref.watch(contentPreferencesProvider).valueOrNull?.creativeStyle ??
      CreativeStyle.balanced;
});

/// Provider for mature content enabled status
final matureContentEnabledProvider = Provider<bool>((ref) {
  return ref.watch(contentPreferencesProvider).valueOrNull?.matureContentEnabled ??
      false;
});

// =============================================================================
// Local Notification Scheduler Provider
// =============================================================================

/// Provider for LocalNotificationService instance
final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
  return LocalNotificationService.instance;
});

/// State class for notification scheduling
class NotificationSchedulerState {
  const NotificationSchedulerState({
    this.isInitialized = false,
    this.hasPermission = false,
    this.isLoading = false,
  });

  final bool isInitialized;
  final bool hasPermission;
  final bool isLoading;

  NotificationSchedulerState copyWith({
    bool? isInitialized,
    bool? hasPermission,
    bool? isLoading,
  }) {
    return NotificationSchedulerState(
      isInitialized: isInitialized ?? this.isInitialized,
      hasPermission: hasPermission ?? this.hasPermission,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier for managing notification scheduling
/// Coordinates between notification settings and the actual notification service
class NotificationSchedulerNotifier extends Notifier<NotificationSchedulerState> {
  late LocalNotificationService _service;

  @override
  NotificationSchedulerState build() {
    _service = ref.watch(localNotificationServiceProvider);

    // Listen to notification settings changes
    ref.listen<AsyncValue<NotificationSettings>>(
      notificationSettingsProvider,
      (previous, next) {
        next.whenData((settings) => _syncNotifications(settings));
      },
    );

    return NotificationSchedulerState(
      isInitialized: _service.isInitialized,
    );
  }

  /// Initialize the notification service
  Future<void> initialize() async {
    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true);
    await _service.initialize();
    state = state.copyWith(
      isInitialized: true,
      isLoading: false,
    );
  }

  /// Request notification permissions
  /// Returns true if permissions were granted
  Future<bool> requestPermission() async {
    state = state.copyWith(isLoading: true);
    final granted = await _service.requestPermission();
    state = state.copyWith(
      hasPermission: granted,
      isLoading: false,
    );
    return granted;
  }

  /// Check if notifications are permitted
  Future<bool> checkPermission() async {
    final hasPermission = await _service.hasPermission();
    state = state.copyWith(hasPermission: hasPermission);
    return hasPermission;
  }

  /// Sync scheduled notifications with current settings
  Future<void> _syncNotifications(NotificationSettings settings) async {
    if (!state.isInitialized) return;

    // Get current streak from dashboard
    final dashboardState = ref.read(dashboardProvider);
    final currentStreak = dashboardState.valueOrNull?.userStats.currentStreak ?? 0;

    // Schedule or cancel streak reminder based on Daily Ritual setting
    if (settings.dailyRitual) {
      await _service.scheduleStreakReminder(currentStreak: currentStreak);
      await _service.scheduleDailyCheckIn();
    } else {
      await _service.cancelStreakReminder();
      await _service.cancelDailyCheckIn();
    }
  }

  /// Manually schedule streak reminder with current streak
  Future<void> scheduleStreakReminder() async {
    if (!state.isInitialized) return;

    final dashboardState = ref.read(dashboardProvider);
    final currentStreak = dashboardState.valueOrNull?.userStats.currentStreak ?? 0;
    await _service.scheduleStreakReminder(currentStreak: currentStreak);
  }

  /// Manually schedule daily check-in
  Future<void> scheduleDailyCheckIn() async {
    if (!state.isInitialized) return;
    await _service.scheduleDailyCheckIn();
  }

  /// Show achievement notification
  Future<void> showAchievementNotification({
    required String title,
    required String description,
    required int achievementId,
  }) async {
    if (!state.isInitialized) return;
    await _service.showAchievementUnlocked(
      achievementTitle: title,
      achievementDescription: description,
      achievementId: achievementId,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _service.cancelAllNotifications();
  }
}

/// Provider for notification scheduler
final notificationSchedulerProvider =
    NotifierProvider<NotificationSchedulerNotifier, NotificationSchedulerState>(
  NotificationSchedulerNotifier.new,
);
