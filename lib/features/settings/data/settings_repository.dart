import 'package:shared_preferences/shared_preferences.dart';

/// Keys for settings storage
abstract class SettingsKeys {
  // Appearance
  static const String textScaleFactor = 'text_scale_factor';

  // Notifications - Per Damien's spec, all OFF by default except systemUpdates
  static const String notifyDailyRitual = 'notify_daily_ritual';
  static const String notifyCreationComplete = 'notify_creation_complete';
  static const String notifyMoodInsights = 'notify_mood_insights';
  static const String notifySystemUpdates = 'notify_system_updates';

  // Content Preferences
  static const String creativeStyle = 'creative_style';
  static const String matureContentEnabled = 'mature_content_enabled';
}

/// Text size options with their scale factors
enum TextSizeOption {
  small(0.85, 'Small'),
  medium(1.0, 'Medium'),
  large(1.15, 'Large'),
  extraLarge(1.3, 'Extra Large');

  const TextSizeOption(this.scaleFactor, this.label);

  final double scaleFactor;
  final String label;

  /// Get option from scale factor
  static TextSizeOption fromScaleFactor(double factor) {
    return TextSizeOption.values.firstWhere(
      (option) => option.scaleFactor == factor,
      orElse: () => TextSizeOption.medium,
    );
  }
}

/// Notification settings state
/// Based on Damien's spec - all OFF by default except System Updates
class NotificationSettings {
  const NotificationSettings({
    this.dailyRitual = false,
    this.creationComplete = false,
    this.moodInsights = false,
    this.systemUpdates = true, // ON by default per spec
  });

  /// Daily Mirror Ritual reminder
  /// "Your daily mirror is ready when you are."
  final bool dailyRitual;

  /// Creation Completion (video/game generation complete)
  /// "Your creation is ready."
  final bool creationComplete;

  /// Mood/Health Insights (stress patterns, sleep correlations)
  /// Optional opt-in only
  final bool moodInsights;

  /// System Updates (security patches, new features)
  /// Required by App Store policies
  final bool systemUpdates;

  NotificationSettings copyWith({
    bool? dailyRitual,
    bool? creationComplete,
    bool? moodInsights,
    bool? systemUpdates,
  }) {
    return NotificationSettings(
      dailyRitual: dailyRitual ?? this.dailyRitual,
      creationComplete: creationComplete ?? this.creationComplete,
      moodInsights: moodInsights ?? this.moodInsights,
      systemUpdates: systemUpdates ?? this.systemUpdates,
    );
  }

  /// Check if any notification is enabled
  bool get hasAnyEnabled =>
      dailyRitual || creationComplete || moodInsights || systemUpdates;

  /// Count of enabled notifications
  int get enabledCount =>
      (dailyRitual ? 1 : 0) +
      (creationComplete ? 1 : 0) +
      (moodInsights ? 1 : 0) +
      (systemUpdates ? 1 : 0);
}

// =============================================================================
// Content Preferences
// =============================================================================

/// Creative style options for AI responses
enum CreativeStyle {
  balanced('balanced', 'Balanced', 'Warm, thoughtful responses'),
  casual('casual', 'Casual', 'Relaxed, friendly, conversational'),
  reflective('reflective', 'Reflective', 'Deeper, more contemplative'),
  concise('concise', 'Concise', 'Brief, direct responses');

  const CreativeStyle(this.key, this.label, this.description);

  /// Key used for storage
  final String key;

  /// Display label
  final String label;

  /// Description of this style
  final String description;

  /// Get style from storage key
  static CreativeStyle fromKey(String? key) {
    return CreativeStyle.values.firstWhere(
      (style) => style.key == key,
      orElse: () => CreativeStyle.balanced,
    );
  }
}

/// Content preferences settings
class ContentPreferences {
  const ContentPreferences({
    this.creativeStyle = CreativeStyle.balanced,
    this.matureContentEnabled = false,
  });

  /// The preferred creative style for AI responses
  final CreativeStyle creativeStyle;

  /// Whether mature/adult content is enabled
  /// Default: false (SFW) for App Store compliance
  final bool matureContentEnabled;

  ContentPreferences copyWith({
    CreativeStyle? creativeStyle,
    bool? matureContentEnabled,
  }) {
    return ContentPreferences(
      creativeStyle: creativeStyle ?? this.creativeStyle,
      matureContentEnabled: matureContentEnabled ?? this.matureContentEnabled,
    );
  }
}

/// Repository for managing app settings
abstract class SettingsRepository {
  // =========================================================================
  // Text Scale
  // =========================================================================

  /// Get the current text scale factor
  Future<double> getTextScaleFactor();

  /// Set the text scale factor
  Future<void> setTextScaleFactor(double factor);

  // =========================================================================
  // Notifications
  // =========================================================================

  /// Get all notification settings
  Future<NotificationSettings> getNotificationSettings();

  /// Set daily ritual notification
  Future<void> setDailyRitualEnabled(bool enabled);

  /// Set creation complete notification
  Future<void> setCreationCompleteEnabled(bool enabled);

  /// Set mood insights notification
  Future<void> setMoodInsightsEnabled(bool enabled);

  /// Set system updates notification
  Future<void> setSystemUpdatesEnabled(bool enabled);

  // =========================================================================
  // Content Preferences
  // =========================================================================

  /// Get all content preferences
  Future<ContentPreferences> getContentPreferences();

  /// Set the creative style preference
  Future<void> setCreativeStyle(CreativeStyle style);

  /// Set mature content enabled
  Future<void> setMatureContentEnabled(bool enabled);

  // =========================================================================
  // Reset
  // =========================================================================

  /// Clear all settings (reset to defaults)
  Future<void> clearAllSettings();
}

/// Implementation of SettingsRepository using SharedPreferences
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({
    required SharedPreferences preferences,
  }) : _prefs = preferences;

  final SharedPreferences _prefs;

  // =========================================================================
  // Text Scale
  // =========================================================================

  @override
  Future<double> getTextScaleFactor() async {
    return _prefs.getDouble(SettingsKeys.textScaleFactor) ?? 1.0;
  }

  @override
  Future<void> setTextScaleFactor(double factor) async {
    await _prefs.setDouble(SettingsKeys.textScaleFactor, factor);
  }

  // =========================================================================
  // Notifications
  // =========================================================================

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    return NotificationSettings(
      dailyRitual: _prefs.getBool(SettingsKeys.notifyDailyRitual) ?? false,
      creationComplete: _prefs.getBool(SettingsKeys.notifyCreationComplete) ?? false,
      moodInsights: _prefs.getBool(SettingsKeys.notifyMoodInsights) ?? false,
      systemUpdates: _prefs.getBool(SettingsKeys.notifySystemUpdates) ?? true,
    );
  }

  @override
  Future<void> setDailyRitualEnabled(bool enabled) async {
    await _prefs.setBool(SettingsKeys.notifyDailyRitual, enabled);
  }

  @override
  Future<void> setCreationCompleteEnabled(bool enabled) async {
    await _prefs.setBool(SettingsKeys.notifyCreationComplete, enabled);
  }

  @override
  Future<void> setMoodInsightsEnabled(bool enabled) async {
    await _prefs.setBool(SettingsKeys.notifyMoodInsights, enabled);
  }

  @override
  Future<void> setSystemUpdatesEnabled(bool enabled) async {
    await _prefs.setBool(SettingsKeys.notifySystemUpdates, enabled);
  }

  // =========================================================================
  // Content Preferences
  // =========================================================================

  @override
  Future<ContentPreferences> getContentPreferences() async {
    return ContentPreferences(
      creativeStyle: CreativeStyle.fromKey(
        _prefs.getString(SettingsKeys.creativeStyle),
      ),
      matureContentEnabled:
          _prefs.getBool(SettingsKeys.matureContentEnabled) ?? false,
    );
  }

  @override
  Future<void> setCreativeStyle(CreativeStyle style) async {
    await _prefs.setString(SettingsKeys.creativeStyle, style.key);
  }

  @override
  Future<void> setMatureContentEnabled(bool enabled) async {
    await _prefs.setBool(SettingsKeys.matureContentEnabled, enabled);
  }

  // =========================================================================
  // Reset
  // =========================================================================

  @override
  Future<void> clearAllSettings() async {
    await Future.wait([
      _prefs.remove(SettingsKeys.textScaleFactor),
      _prefs.remove(SettingsKeys.notifyDailyRitual),
      _prefs.remove(SettingsKeys.notifyCreationComplete),
      _prefs.remove(SettingsKeys.notifyMoodInsights),
      _prefs.remove(SettingsKeys.notifySystemUpdates),
      _prefs.remove(SettingsKeys.creativeStyle),
      _prefs.remove(SettingsKeys.matureContentEnabled),
    ]);
  }
}
