// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Apothy';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get continueButton => 'Continue';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsNotSignedIn => 'Not signed in';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsManageNotifications => 'Manage Notifications';

  @override
  String settingsNotificationsCount(int count) {
    return '$count of 4 enabled';
  }

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsTextSize => 'Text Size';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsContent => 'Content';

  @override
  String get settingsContentPreferences => 'Content Preferences';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsClearChatHistory => 'Clear Chat History';

  @override
  String get settingsClearChatHistorySubtitle =>
      'Delete conversations and memory';

  @override
  String get settingsAdvanced => 'Advanced';

  @override
  String get settingsAdvancedSubtitle => 'Reset app to fresh state';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsDataPrivacy => 'Data Privacy';

  @override
  String get settingsDataPrivacySubtitle => 'How your data is handled';

  @override
  String get settingsDangerZone => 'Danger Zone';

  @override
  String get settingsDeleteAccount => 'Delete Account';

  @override
  String get settingsDeleteAccountSubtitle => 'Permanently delete your account';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutApothy => 'About Apothy';

  @override
  String get settingsVersion => 'Version 1.0.0';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsTermsSubtitle => 'Read our terms';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsPrivacyPolicySubtitle => 'Read our privacy policy';

  @override
  String get settingsSignOut => 'Sign Out';

  @override
  String get settingsTapToChangeAvatar => 'Tap to change avatar';

  @override
  String get settingsDisplayName => 'Display Name';

  @override
  String get settingsEmail => 'Email';

  @override
  String get settingsNotAvailable => 'Not available';

  @override
  String get settingsSignInMethod => 'Sign-in Method';

  @override
  String get settingsChooseAvatar => 'Choose Avatar';

  @override
  String get settingsFailedToUpdateAvatar => 'Failed to update avatar';

  @override
  String get settingsEditDisplayName => 'Edit Display Name';

  @override
  String get settingsEnterYourName => 'Enter your name';

  @override
  String get settingsNameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get settingsFailedToUpdateName => 'Failed to update name';

  @override
  String get settingsAuthProviderApple => 'Apple';

  @override
  String get settingsAuthProviderGoogle => 'Google';

  @override
  String get settingsAuthProviderEmail => 'Email';

  @override
  String get settingsAuthProviderUnknown => 'Unknown';

  @override
  String get settingsNotificationsDescription =>
      'Apothy respects your attention. No manipulation, no spam.';

  @override
  String get settingsDailyMirrorRitual => 'Daily Mirror Ritual';

  @override
  String get settingsDailyMirrorRitualDescription =>
      'A gentle reminder when your daily mirror is ready';

  @override
  String get settingsCreationComplete => 'Creation Complete';

  @override
  String get settingsCreationCompleteDescription =>
      'Know when long-form creations (videos, games) are ready';

  @override
  String get settingsMoodHealthInsights => 'Mood & Health Insights';

  @override
  String get settingsMoodHealthInsightsDescription =>
      'Stress patterns, sleep correlations, ritual streaks';

  @override
  String get settingsMoodHealthInsightsExample =>
      'Optional wellness insights based on your usage';

  @override
  String get settingsSystemUpdates => 'System Updates';

  @override
  String get settingsSystemUpdatesDescription =>
      'Security patches and new features';

  @override
  String get settingsSystemUpdatesExample =>
      'Required for App Store compliance';

  @override
  String get settingsThemeDialogMessage =>
      'Apothy currently supports dark mode only. Light mode and additional themes may be added in future updates.';

  @override
  String get settingsChooseTextSize => 'Choose your preferred text size';

  @override
  String get settingsSystemDefault => 'System Default';

  @override
  String get settingsUseDeviceLanguage => 'Use device language';

  @override
  String get settingsChooseLanguage => 'Choose your preferred language';

  @override
  String get settingsContentPreferencesDescription =>
      'Customize how Apotheon communicates with you.';

  @override
  String get settingsCreativeStyle => 'Creative Style';

  @override
  String get settingsCreativeStyleDescription =>
      'Choose how Apotheon responds to you';

  @override
  String get settingsMatureContent => 'Mature Content';

  @override
  String get settingsMatureContentDescription =>
      'Allow adult themes in responses';

  @override
  String get settingsMatureContentEnabled =>
      'Adult themes enabled. Use responsibly.';

  @override
  String get settingsMatureContentDisabled => 'Safe for work (SFW) - Default';

  @override
  String get settingsPrivacyDialogMessage =>
      'Your data is stored securely on your device. Conversations are processed to provide personalized responses but are never sold or shared with third parties.\n\nYou can delete your data at any time using the \"Clear Data\" option.';

  @override
  String get settingsClearChatHistoryDialogTitle => 'Clear Chat History';

  @override
  String get settingsClearChatHistoryDialogMessage => 'This will delete:';

  @override
  String get settingsClearChatHistoryItem1 => '• All chat conversations';

  @override
  String get settingsClearChatHistoryItem2 =>
      '• Conversation memory and context';

  @override
  String get settingsClearChatHistoryItem3 => '• Chat-related preferences';

  @override
  String get settingsClearChatHistoryNote =>
      'Your account, settings, and any exported files will not be affected.';

  @override
  String get settingsClearChatHistorySuccess => 'Chat history cleared';

  @override
  String get settingsClearChatHistoryFailed => 'Failed to clear chat history';

  @override
  String get settingsClearHistoryButton => 'Clear History';

  @override
  String get settingsAdvancedDataManagement => 'Advanced Data Management';

  @override
  String get settingsAdvancedWarning => 'These actions are irreversible.';

  @override
  String get settingsResetToFreshState => 'Reset to Fresh State';

  @override
  String get settingsResetDescription =>
      'This will erase ALL local data and reset the app to its initial state, as if you just installed it.';

  @override
  String get settingsResetWhatGetsCleared =>
      'What gets cleared:\n• All conversations and chat history\n• Account credentials (you\'ll need to sign in again)\n• All settings and preferences\n• Emotion challenge history\n• Any cached data';

  @override
  String get settingsResetNote =>
      'Your cloud account and subscription remain intact.';

  @override
  String get settingsResetAppButton => 'Reset App';

  @override
  String get settingsResetConfirmTitle => 'Are you sure?';

  @override
  String get settingsResetConfirmMessage =>
      'Resetting will erase all local data. This cannot be undone.\n\nYou will need to sign in again and complete onboarding.';

  @override
  String get settingsResetFailed => 'Failed to reset app';

  @override
  String get settingsResetEverythingButton => 'Reset Everything';

  @override
  String get settingsDeleteAccountDialogMessage =>
      'This will permanently delete your account.';

  @override
  String get settingsDeleteAccountWhatGetsDeleted => 'What gets deleted:';

  @override
  String get settingsDeleteAccountItem1 => '• Your Apothy account';

  @override
  String get settingsDeleteAccountItem2 =>
      '• All conversation history (cloud & local)';

  @override
  String get settingsDeleteAccountItem3 => '• Profile and preferences';

  @override
  String get settingsDeleteAccountItem4 => '• Emotion challenge data';

  @override
  String get settingsDeleteAccountItem5 => '• All devices will be signed out';

  @override
  String get settingsDeleteAccountSubscriptionNote =>
      'Subscriptions are managed through your App Store.';

  @override
  String get settingsDeleteAccountButton => 'Delete Account';

  @override
  String get settingsFinalConfirmation => 'Final Confirmation';

  @override
  String get settingsFinalConfirmationMessage =>
      'Deleting your account erases all cloud data and unlinks all devices. This action cannot be undone.\n\nAre you absolutely sure?';

  @override
  String get settingsKeepAccountButton => 'Keep Account';

  @override
  String get settingsDeleteAccountFailed => 'Failed to delete account';

  @override
  String get settingsDeleteForeverButton => 'Delete Forever';

  @override
  String get settingsAboutDescription =>
      'Your AI companion for meaningful conversations and personal growth. Born from light. Trained in truth. Built to become what you need.';

  @override
  String get settingsTermsOfServiceContent =>
      'TERMS OF SERVICE\n\nLast updated: December 2024\n\nBy using Apothy, you agree to these terms of service.\n\nApothy is an AI companion designed for personal growth and meaningful conversations. You agree to use the service responsibly.\n\nYour privacy is important to us. Please review our Privacy Policy for details on how we handle your data.\n\nConversations are private and stored securely. We do not share your data with third parties.\n\nWe may update these terms from time to time. Continued use constitutes acceptance of changes.\n\nFor questions about these terms, please contact us through the app.';

  @override
  String get settingsPrivacyPolicyContent =>
      'PRIVACY POLICY\n\nLast updated: December 2024\n\nWe collect information you provide directly, such as account details and conversation history.\n\nWe use your information to provide and improve the Apothy experience, including personalized responses.\n\nYour data is stored securely on your device and our servers with encryption.\n\nWe do not sell or share your personal data with third parties for marketing purposes.\n\nYou can access, modify, or delete your data at any time through the app settings.\n\nWe implement industry-standard security measures to protect your data.\n\nFor privacy-related questions, please contact us through the app.';

  @override
  String get settingsSignOutConfirmMessage =>
      'Are you sure you want to sign out?';
}
