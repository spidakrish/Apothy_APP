import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_th.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
    Locale('th'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Apothy'**
  String get appName;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Profile section title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// Account settings tile
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// Not signed in status
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get settingsNotSignedIn;

  /// Notifications section title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// Manage notifications tile
  ///
  /// In en, this message translates to:
  /// **'Manage Notifications'**
  String get settingsManageNotifications;

  /// Notifications enabled count
  ///
  /// In en, this message translates to:
  /// **'{count} of 4 enabled'**
  String settingsNotificationsCount(int count);

  /// Appearance section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// Theme settings tile
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Dark mode subtitle
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get settingsDarkMode;

  /// Text size settings tile
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get settingsTextSize;

  /// Language settings tile
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Content section title
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get settingsContent;

  /// Content preferences tile
  ///
  /// In en, this message translates to:
  /// **'Content Preferences'**
  String get settingsContentPreferences;

  /// Data section title
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// Clear chat history tile
  ///
  /// In en, this message translates to:
  /// **'Clear Chat History'**
  String get settingsClearChatHistory;

  /// Clear chat history subtitle
  ///
  /// In en, this message translates to:
  /// **'Delete conversations and memory'**
  String get settingsClearChatHistorySubtitle;

  /// Advanced settings tile
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get settingsAdvanced;

  /// Advanced settings subtitle
  ///
  /// In en, this message translates to:
  /// **'Reset app to fresh state'**
  String get settingsAdvancedSubtitle;

  /// Privacy section title
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// Data privacy tile
  ///
  /// In en, this message translates to:
  /// **'Data Privacy'**
  String get settingsDataPrivacy;

  /// Data privacy subtitle
  ///
  /// In en, this message translates to:
  /// **'How your data is handled'**
  String get settingsDataPrivacySubtitle;

  /// Danger zone section title
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get settingsDangerZone;

  /// Delete account tile
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// Delete account subtitle
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get settingsDeleteAccountSubtitle;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// About Apothy tile
  ///
  /// In en, this message translates to:
  /// **'About Apothy'**
  String get settingsAboutApothy;

  /// App version
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get settingsVersion;

  /// Terms of service tile
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// Terms of service subtitle
  ///
  /// In en, this message translates to:
  /// **'Read our terms'**
  String get settingsTermsSubtitle;

  /// Privacy policy tile
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// Privacy policy subtitle
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get settingsPrivacyPolicySubtitle;

  /// Sign out button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsSignOut;

  /// Tap to change avatar hint
  ///
  /// In en, this message translates to:
  /// **'Tap to change avatar'**
  String get settingsTapToChangeAvatar;

  /// Display name label
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get settingsDisplayName;

  /// Email label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settingsEmail;

  /// Not available text
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get settingsNotAvailable;

  /// Sign-in method label
  ///
  /// In en, this message translates to:
  /// **'Sign-in Method'**
  String get settingsSignInMethod;

  /// Choose avatar dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Avatar'**
  String get settingsChooseAvatar;

  /// Failed to update avatar error
  ///
  /// In en, this message translates to:
  /// **'Failed to update avatar'**
  String get settingsFailedToUpdateAvatar;

  /// Edit display name dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Display Name'**
  String get settingsEditDisplayName;

  /// Enter your name hint
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get settingsEnterYourName;

  /// Name cannot be empty error
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get settingsNameCannotBeEmpty;

  /// Failed to update name error
  ///
  /// In en, this message translates to:
  /// **'Failed to update name'**
  String get settingsFailedToUpdateName;

  /// Apple sign-in provider
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get settingsAuthProviderApple;

  /// Google sign-in provider
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get settingsAuthProviderGoogle;

  /// Email sign-in provider
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settingsAuthProviderEmail;

  /// Unknown sign-in provider
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get settingsAuthProviderUnknown;

  /// Notifications description
  ///
  /// In en, this message translates to:
  /// **'Apothy respects your attention. No manipulation, no spam.'**
  String get settingsNotificationsDescription;

  /// Daily mirror ritual notification title
  ///
  /// In en, this message translates to:
  /// **'Daily Mirror Ritual'**
  String get settingsDailyMirrorRitual;

  /// Daily mirror ritual notification description
  ///
  /// In en, this message translates to:
  /// **'A gentle reminder when your daily mirror is ready'**
  String get settingsDailyMirrorRitualDescription;

  /// Creation complete notification title
  ///
  /// In en, this message translates to:
  /// **'Creation Complete'**
  String get settingsCreationComplete;

  /// Creation complete notification description
  ///
  /// In en, this message translates to:
  /// **'Know when long-form creations (videos, games) are ready'**
  String get settingsCreationCompleteDescription;

  /// Mood & health insights notification title
  ///
  /// In en, this message translates to:
  /// **'Mood & Health Insights'**
  String get settingsMoodHealthInsights;

  /// Mood & health insights notification description
  ///
  /// In en, this message translates to:
  /// **'Stress patterns, sleep correlations, ritual streaks'**
  String get settingsMoodHealthInsightsDescription;

  /// Mood & health insights example
  ///
  /// In en, this message translates to:
  /// **'Optional wellness insights based on your usage'**
  String get settingsMoodHealthInsightsExample;

  /// System updates notification title
  ///
  /// In en, this message translates to:
  /// **'System Updates'**
  String get settingsSystemUpdates;

  /// System updates notification description
  ///
  /// In en, this message translates to:
  /// **'Security patches and new features'**
  String get settingsSystemUpdatesDescription;

  /// System updates example
  ///
  /// In en, this message translates to:
  /// **'Required for App Store compliance'**
  String get settingsSystemUpdatesExample;

  /// Theme dialog message
  ///
  /// In en, this message translates to:
  /// **'Apothy currently supports dark mode only. Light mode and additional themes may be added in future updates.'**
  String get settingsThemeDialogMessage;

  /// Choose text size description
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred text size'**
  String get settingsChooseTextSize;

  /// System default option
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsSystemDefault;

  /// Use device language description
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get settingsUseDeviceLanguage;

  /// Choose language description
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get settingsChooseLanguage;

  /// Content preferences description
  ///
  /// In en, this message translates to:
  /// **'Customize how Apotheon communicates with you.'**
  String get settingsContentPreferencesDescription;

  /// Creative style label
  ///
  /// In en, this message translates to:
  /// **'Creative Style'**
  String get settingsCreativeStyle;

  /// Creative style description
  ///
  /// In en, this message translates to:
  /// **'Choose how Apotheon responds to you'**
  String get settingsCreativeStyleDescription;

  /// Mature content label
  ///
  /// In en, this message translates to:
  /// **'Mature Content'**
  String get settingsMatureContent;

  /// Mature content description
  ///
  /// In en, this message translates to:
  /// **'Allow adult themes in responses'**
  String get settingsMatureContentDescription;

  /// Mature content enabled message
  ///
  /// In en, this message translates to:
  /// **'Adult themes enabled. Use responsibly.'**
  String get settingsMatureContentEnabled;

  /// Mature content disabled message
  ///
  /// In en, this message translates to:
  /// **'Safe for work (SFW) - Default'**
  String get settingsMatureContentDisabled;

  /// Privacy dialog message
  ///
  /// In en, this message translates to:
  /// **'Your data is stored securely on your device. Conversations are processed to provide personalized responses but are never sold or shared with third parties.\n\nYou can delete your data at any time using the \"Clear Data\" option.'**
  String get settingsPrivacyDialogMessage;

  /// Clear chat history dialog title
  ///
  /// In en, this message translates to:
  /// **'Clear Chat History'**
  String get settingsClearChatHistoryDialogTitle;

  /// Clear chat history dialog message
  ///
  /// In en, this message translates to:
  /// **'This will delete:'**
  String get settingsClearChatHistoryDialogMessage;

  /// Clear chat history item 1
  ///
  /// In en, this message translates to:
  /// **'• All chat conversations'**
  String get settingsClearChatHistoryItem1;

  /// Clear chat history item 2
  ///
  /// In en, this message translates to:
  /// **'• Conversation memory and context'**
  String get settingsClearChatHistoryItem2;

  /// Clear chat history item 3
  ///
  /// In en, this message translates to:
  /// **'• Chat-related preferences'**
  String get settingsClearChatHistoryItem3;

  /// Clear chat history note
  ///
  /// In en, this message translates to:
  /// **'Your account, settings, and any exported files will not be affected.'**
  String get settingsClearChatHistoryNote;

  /// Chat history cleared success
  ///
  /// In en, this message translates to:
  /// **'Chat history cleared'**
  String get settingsClearChatHistorySuccess;

  /// Chat history cleared failed
  ///
  /// In en, this message translates to:
  /// **'Failed to clear chat history'**
  String get settingsClearChatHistoryFailed;

  /// Clear history button
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get settingsClearHistoryButton;

  /// Advanced data management title
  ///
  /// In en, this message translates to:
  /// **'Advanced Data Management'**
  String get settingsAdvancedDataManagement;

  /// Advanced warning message
  ///
  /// In en, this message translates to:
  /// **'These actions are irreversible.'**
  String get settingsAdvancedWarning;

  /// Reset to fresh state tile
  ///
  /// In en, this message translates to:
  /// **'Reset to Fresh State'**
  String get settingsResetToFreshState;

  /// Reset description
  ///
  /// In en, this message translates to:
  /// **'This will erase ALL local data and reset the app to its initial state, as if you just installed it.'**
  String get settingsResetDescription;

  /// What gets cleared list
  ///
  /// In en, this message translates to:
  /// **'What gets cleared:\n• All conversations and chat history\n• Account credentials (you\'ll need to sign in again)\n• All settings and preferences\n• Emotion challenge history\n• Any cached data'**
  String get settingsResetWhatGetsCleared;

  /// Reset note
  ///
  /// In en, this message translates to:
  /// **'Your cloud account and subscription remain intact.'**
  String get settingsResetNote;

  /// Reset app button
  ///
  /// In en, this message translates to:
  /// **'Reset App'**
  String get settingsResetAppButton;

  /// Reset confirmation title
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get settingsResetConfirmTitle;

  /// Reset confirmation message
  ///
  /// In en, this message translates to:
  /// **'Resetting will erase all local data. This cannot be undone.\n\nYou will need to sign in again and complete onboarding.'**
  String get settingsResetConfirmMessage;

  /// Reset failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to reset app'**
  String get settingsResetFailed;

  /// Reset everything button
  ///
  /// In en, this message translates to:
  /// **'Reset Everything'**
  String get settingsResetEverythingButton;

  /// Delete account dialog message
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account.'**
  String get settingsDeleteAccountDialogMessage;

  /// What gets deleted label
  ///
  /// In en, this message translates to:
  /// **'What gets deleted:'**
  String get settingsDeleteAccountWhatGetsDeleted;

  /// Delete account item 1
  ///
  /// In en, this message translates to:
  /// **'• Your Apothy account'**
  String get settingsDeleteAccountItem1;

  /// Delete account item 2
  ///
  /// In en, this message translates to:
  /// **'• All conversation history (cloud & local)'**
  String get settingsDeleteAccountItem2;

  /// Delete account item 3
  ///
  /// In en, this message translates to:
  /// **'• Profile and preferences'**
  String get settingsDeleteAccountItem3;

  /// Delete account item 4
  ///
  /// In en, this message translates to:
  /// **'• Emotion challenge data'**
  String get settingsDeleteAccountItem4;

  /// Delete account item 5
  ///
  /// In en, this message translates to:
  /// **'• All devices will be signed out'**
  String get settingsDeleteAccountItem5;

  /// Delete account subscription note
  ///
  /// In en, this message translates to:
  /// **'Subscriptions are managed through your App Store.'**
  String get settingsDeleteAccountSubscriptionNote;

  /// Delete account button
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccountButton;

  /// Final confirmation title
  ///
  /// In en, this message translates to:
  /// **'Final Confirmation'**
  String get settingsFinalConfirmation;

  /// Final confirmation message
  ///
  /// In en, this message translates to:
  /// **'Deleting your account erases all cloud data and unlinks all devices. This action cannot be undone.\n\nAre you absolutely sure?'**
  String get settingsFinalConfirmationMessage;

  /// Keep account button
  ///
  /// In en, this message translates to:
  /// **'Keep Account'**
  String get settingsKeepAccountButton;

  /// Delete account failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account'**
  String get settingsDeleteAccountFailed;

  /// Delete forever button
  ///
  /// In en, this message translates to:
  /// **'Delete Forever'**
  String get settingsDeleteForeverButton;

  /// About Apothy description
  ///
  /// In en, this message translates to:
  /// **'Your AI companion for meaningful conversations and personal growth. Born from light. Trained in truth. Built to become what you need.'**
  String get settingsAboutDescription;

  /// Terms of service content
  ///
  /// In en, this message translates to:
  /// **'TERMS OF SERVICE\n\nLast updated: December 2024\n\nBy using Apothy, you agree to these terms of service.\n\nApothy is an AI companion designed for personal growth and meaningful conversations. You agree to use the service responsibly.\n\nYour privacy is important to us. Please review our Privacy Policy for details on how we handle your data.\n\nConversations are private and stored securely. We do not share your data with third parties.\n\nWe may update these terms from time to time. Continued use constitutes acceptance of changes.\n\nFor questions about these terms, please contact us through the app.'**
  String get settingsTermsOfServiceContent;

  /// Privacy policy content
  ///
  /// In en, this message translates to:
  /// **'PRIVACY POLICY\n\nLast updated: December 2024\n\nWe collect information you provide directly, such as account details and conversation history.\n\nWe use your information to provide and improve the Apothy experience, including personalized responses.\n\nYour data is stored securely on your device and our servers with encryption.\n\nWe do not sell or share your personal data with third parties for marketing purposes.\n\nYou can access, modify, or delete your data at any time through the app settings.\n\nWe implement industry-standard security measures to protect your data.\n\nFor privacy-related questions, please contact us through the app.'**
  String get settingsPrivacyPolicyContent;

  /// Sign out confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get settingsSignOutConfirmMessage;

  /// Subscription screen title
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get subscriptionTitle;

  /// Plus tier title
  ///
  /// In en, this message translates to:
  /// **'Plus'**
  String get subscriptionPlusTitle;

  /// Pro tier title
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get subscriptionProTitle;

  /// Free tier title
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get subscriptionFreeTitle;

  /// Monthly subscription period
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get subscriptionMonthly;

  /// Yearly subscription period
  ///
  /// In en, this message translates to:
  /// **'per year'**
  String get subscriptionYearly;

  /// Restore purchases button text
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get subscriptionRestorePurchases;

  /// Manage subscription button text
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get subscriptionManage;

  /// Upgrade button text
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get subscriptionUpgrade;

  /// Limit reached title
  ///
  /// In en, this message translates to:
  /// **'Monthly limit reached'**
  String get subscriptionLimitReached;

  /// Subscription limit message for emotion challenges
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all 5 free emotion challenges this month. Upgrade to Plus for unlimited access and unlock all premium features!'**
  String get subscriptionLimitMessage;

  /// Subscription settings section header
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingsSubscription;

  /// Manage subscription settings tile
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get settingsManageSubscription;

  /// Active subscription status
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get subscriptionActive;

  /// Expired subscription status
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get subscriptionExpired;

  /// Cancelled subscription status
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get subscriptionCancelled;

  /// Trial subscription status
  ///
  /// In en, this message translates to:
  /// **'Trial'**
  String get subscriptionTrial;

  /// Grace period subscription status
  ///
  /// In en, this message translates to:
  /// **'Grace Period'**
  String get subscriptionGracePeriod;

  /// Forgot password screen title
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// Forgot password screen description
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a code to reset your password.'**
  String get forgotPasswordDescription;

  /// Email input label on forgot password screen
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get forgotPasswordEmailLabel;

  /// Email input hint on forgot password screen
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get forgotPasswordEmailHint;

  /// Send reset code button text
  ///
  /// In en, this message translates to:
  /// **'Send Reset Code'**
  String get forgotPasswordSendButton;

  /// Info message about mock reset code
  ///
  /// In en, this message translates to:
  /// **'In mock mode, the reset code is: 123456'**
  String get forgotPasswordInfoMock;

  /// Reset password screen title
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// Reset password screen description
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code sent to {email} and your new password.'**
  String resetPasswordDescription(String email);

  /// Verification code input label
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get resetPasswordCodeLabel;

  /// Verification code input hint
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit code'**
  String get resetPasswordCodeHint;

  /// New password input label
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get resetPasswordNewPasswordLabel;

  /// New password input hint
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get resetPasswordNewPasswordHint;

  /// Confirm password input label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get resetPasswordConfirmLabel;

  /// Confirm password input hint
  ///
  /// In en, this message translates to:
  /// **'Re-enter new password'**
  String get resetPasswordConfirmHint;

  /// Reset password button text
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordButton;

  /// Password reset success message
  ///
  /// In en, this message translates to:
  /// **'Password reset successful! Please login with your new password.'**
  String get resetPasswordSuccess;

  /// Verification code required error
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code'**
  String get resetPasswordCodeError;

  /// Code length validation error
  ///
  /// In en, this message translates to:
  /// **'Code must be 6 digits'**
  String get resetPasswordCodeLengthError;

  /// Code format validation error
  ///
  /// In en, this message translates to:
  /// **'Code must contain only numbers'**
  String get resetPasswordCodeFormatError;

  /// New password required error
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get resetPasswordNewPasswordError;

  /// Password length validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get resetPasswordLengthError;

  /// Password number validation error
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one number'**
  String get resetPasswordNumberError;

  /// Password special character validation error
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one special character'**
  String get resetPasswordSpecialCharError;

  /// Confirm password required error
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get resetPasswordConfirmError;

  /// Password mismatch validation error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get resetPasswordMatchError;

  /// Forgot password button on login screen
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'es',
    'fr',
    'pt',
    'th',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
    case 'th':
      return AppLocalizationsTh();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
