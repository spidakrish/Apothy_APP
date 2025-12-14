// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Apothy';

  @override
  String get ok => '确定';

  @override
  String get cancel => '取消';

  @override
  String get continueButton => '继续';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get loading => '加载中...';

  @override
  String get error => '错误';

  @override
  String get retry => '重试';

  @override
  String get close => '关闭';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsProfile => '个人资料';

  @override
  String get settingsAccount => '账户';

  @override
  String get settingsNotSignedIn => '未登录';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsManageNotifications => '管理通知';

  @override
  String settingsNotificationsCount(int count) {
    return '已启用 $count 项（共 4 项）';
  }

  @override
  String get settingsAppearance => '外观';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsDarkMode => '深色模式';

  @override
  String get settingsTextSize => '文字大小';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsContent => '内容';

  @override
  String get settingsContentPreferences => '内容偏好';

  @override
  String get settingsData => '数据';

  @override
  String get settingsClearChatHistory => '清除聊天记录';

  @override
  String get settingsClearChatHistorySubtitle => '删除对话和记忆';

  @override
  String get settingsAdvanced => '高级';

  @override
  String get settingsAdvancedSubtitle => '重置应用';

  @override
  String get settingsPrivacy => '隐私';

  @override
  String get settingsDataPrivacy => '数据隐私';

  @override
  String get settingsDataPrivacySubtitle => '了解数据处理方式';

  @override
  String get settingsDangerZone => '危险区域';

  @override
  String get settingsDeleteAccount => '删除账户';

  @override
  String get settingsDeleteAccountSubtitle => '永久删除您的账户';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsAboutApothy => '关于 Apothy';

  @override
  String get settingsVersion => '版本 1.0.0';

  @override
  String get settingsTermsOfService => '服务条款';

  @override
  String get settingsTermsSubtitle => '阅读我们的条款';

  @override
  String get settingsPrivacyPolicy => '隐私政策';

  @override
  String get settingsPrivacyPolicySubtitle => '阅读我们的隐私政策';

  @override
  String get settingsSignOut => '退出登录';

  @override
  String get settingsTapToChangeAvatar => '点击更换头像';

  @override
  String get settingsDisplayName => '显示名称';

  @override
  String get settingsEmail => '电子邮件';

  @override
  String get settingsNotAvailable => '不可用';

  @override
  String get settingsSignInMethod => '登录方式';

  @override
  String get settingsChooseAvatar => '选择头像';

  @override
  String get settingsFailedToUpdateAvatar => '更新头像失败';

  @override
  String get settingsEditDisplayName => '编辑显示名称';

  @override
  String get settingsEnterYourName => '请输入您的姓名';

  @override
  String get settingsNameCannotBeEmpty => '姓名不能为空';

  @override
  String get settingsFailedToUpdateName => '更新姓名失败';

  @override
  String get settingsAuthProviderApple => 'Apple';

  @override
  String get settingsAuthProviderGoogle => 'Google';

  @override
  String get settingsAuthProviderEmail => '电子邮件';

  @override
  String get settingsAuthProviderUnknown => '未知';

  @override
  String get settingsNotificationsDescription => 'Apothy 尊重您的注意力。无操纵，无垃圾信息。';

  @override
  String get settingsDailyMirrorRitual => '每日镜像仪式';

  @override
  String get settingsDailyMirrorRitualDescription => '当每日镜像准备好时温馨提醒您';

  @override
  String get settingsCreationComplete => '创作完成';

  @override
  String get settingsCreationCompleteDescription => '长格式创作（视频、游戏）完成时通知您';

  @override
  String get settingsMoodHealthInsights => '情绪与健康洞察';

  @override
  String get settingsMoodHealthInsightsDescription => '压力模式、睡眠相关性、仪式连胜';

  @override
  String get settingsMoodHealthInsightsExample => '基于您的使用情况提供可选的健康洞察';

  @override
  String get settingsSystemUpdates => '系统更新';

  @override
  String get settingsSystemUpdatesDescription => '安全补丁和新功能';

  @override
  String get settingsSystemUpdatesExample => 'App Store 合规要求';

  @override
  String get settingsThemeDialogMessage =>
      'Apothy 目前仅支持深色模式。浅色模式和其他主题可能会在未来更新中添加。';

  @override
  String get settingsChooseTextSize => '选择您偏好的文字大小';

  @override
  String get settingsSystemDefault => '系统默认';

  @override
  String get settingsUseDeviceLanguage => '使用设备语言';

  @override
  String get settingsChooseLanguage => '选择您偏好的语言';

  @override
  String get settingsContentPreferencesDescription => '自定义 Apotheon 与您的交流方式。';

  @override
  String get settingsCreativeStyle => '创作风格';

  @override
  String get settingsCreativeStyleDescription => '选择 Apotheon 如何回应您';

  @override
  String get settingsMatureContent => '成人内容';

  @override
  String get settingsMatureContentDescription => '允许回复中包含成人主题';

  @override
  String get settingsMatureContentEnabled => '成人主题已启用。请负责任地使用。';

  @override
  String get settingsMatureContentDisabled => '工作安全 (SFW) - 默认';

  @override
  String get settingsPrivacyDialogMessage =>
      '您的数据安全地存储在您的设备上。对话将被处理以提供个性化回复，但绝不会出售或与第三方共享。\n\n您可以随时使用\"清除数据\"选项删除您的数据。';

  @override
  String get settingsClearChatHistoryDialogTitle => '清除聊天记录';

  @override
  String get settingsClearChatHistoryDialogMessage => '这将删除：';

  @override
  String get settingsClearChatHistoryItem1 => '• 所有聊天对话';

  @override
  String get settingsClearChatHistoryItem2 => '• 对话记忆和上下文';

  @override
  String get settingsClearChatHistoryItem3 => '• 聊天相关偏好';

  @override
  String get settingsClearChatHistoryNote => '您的账户、设置和任何导出的文件不会受到影响。';

  @override
  String get settingsClearChatHistorySuccess => '聊天记录已清除';

  @override
  String get settingsClearChatHistoryFailed => '清除聊天记录失败';

  @override
  String get settingsClearHistoryButton => '清除记录';

  @override
  String get settingsAdvancedDataManagement => '高级数据管理';

  @override
  String get settingsAdvancedWarning => '这些操作不可撤销。';

  @override
  String get settingsResetToFreshState => '重置为初始状态';

  @override
  String get settingsResetDescription => '这将清除所有本地数据并将应用重置为初始状态，就像您刚安装一样。';

  @override
  String get settingsResetWhatGetsCleared =>
      '将被清除的内容：\n• 所有对话和聊天记录\n• 账户凭证（您需要重新登录）\n• 所有设置和偏好\n• 情绪挑战历史\n• 所有缓存数据';

  @override
  String get settingsResetNote => '您的云账户和订阅保持不变。';

  @override
  String get settingsResetAppButton => '重置应用';

  @override
  String get settingsResetConfirmTitle => '您确定吗？';

  @override
  String get settingsResetConfirmMessage =>
      '重置将清除所有本地数据。此操作无法撤销。\n\n您需要重新登录并完成引导。';

  @override
  String get settingsResetFailed => '重置应用失败';

  @override
  String get settingsResetEverythingButton => '重置所有内容';

  @override
  String get settingsDeleteAccountDialogMessage => '这将永久删除您的账户。';

  @override
  String get settingsDeleteAccountWhatGetsDeleted => '将被删除的内容：';

  @override
  String get settingsDeleteAccountItem1 => '• 您的 Apothy 账户';

  @override
  String get settingsDeleteAccountItem2 => '• 所有对话历史（云端和本地）';

  @override
  String get settingsDeleteAccountItem3 => '• 个人资料和偏好';

  @override
  String get settingsDeleteAccountItem4 => '• 情绪挑战数据';

  @override
  String get settingsDeleteAccountItem5 => '• 所有设备将被退出登录';

  @override
  String get settingsDeleteAccountSubscriptionNote => '订阅通过您的 App Store 管理。';

  @override
  String get settingsDeleteAccountButton => '删除账户';

  @override
  String get settingsFinalConfirmation => '最终确认';

  @override
  String get settingsFinalConfirmationMessage =>
      '删除您的账户将清除所有云数据并解除所有设备的关联。此操作无法撤销。\n\n您完全确定吗？';

  @override
  String get settingsKeepAccountButton => '保留账户';

  @override
  String get settingsDeleteAccountFailed => '删除账户失败';

  @override
  String get settingsDeleteForeverButton => '永久删除';

  @override
  String get settingsAboutDescription =>
      '您的 AI 伴侣，用于有意义的对话和个人成长。源于光明。基于真理训练。为成为您所需而打造。';

  @override
  String get settingsTermsOfServiceContent =>
      '服务条款\n\n最后更新：2024年12月\n\n使用 Apothy 即表示您同意这些服务条款。\n\nApothy 是一个为个人成长和有意义对话而设计的 AI 伴侣。您同意负责任地使用本服务。\n\n您的隐私对我们很重要。请查看我们的隐私政策，了解我们如何处理您的数据。\n\n对话是私密的并安全存储。我们不会与第三方共享您的数据。\n\n我们可能会不时更新这些条款。继续使用即表示接受更改。\n\n如有关于这些条款的问题，请通过应用与我们联系。';

  @override
  String get settingsPrivacyPolicyContent =>
      '隐私政策\n\n最后更新：2024年12月\n\n我们收集您直接提供的信息，例如账户详情和对话历史。\n\n我们使用您的信息来提供和改善 Apothy 体验，包括个性化回复。\n\n您的数据通过加密安全地存储在您的设备和我们的服务器上。\n\n我们不会出于营销目的出售或与第三方共享您的个人数据。\n\n您可以随时通过应用设置访问、修改或删除您的数据。\n\n我们实施行业标准的安全措施来保护您的数据。\n\n如有隐私相关问题，请通过应用与我们联系。';

  @override
  String get settingsSignOutConfirmMessage => '您确定要退出登录吗？';

  @override
  String get subscriptionTitle => 'Upgrade to Premium';

  @override
  String get subscriptionPlusTitle => 'Plus';

  @override
  String get subscriptionProTitle => 'Pro';

  @override
  String get subscriptionFreeTitle => 'Free';

  @override
  String get subscriptionMonthly => 'per month';

  @override
  String get subscriptionYearly => 'per year';

  @override
  String get subscriptionRestorePurchases => 'Restore Purchases';

  @override
  String get subscriptionManage => 'Manage Subscription';

  @override
  String get subscriptionUpgrade => 'Upgrade Now';

  @override
  String get subscriptionLimitReached => 'Monthly limit reached';

  @override
  String get subscriptionLimitMessage =>
      'You\'ve used all 5 free emotion challenges this month. Upgrade to Plus for unlimited access and unlock all premium features!';

  @override
  String get settingsSubscription => 'Subscription';

  @override
  String get settingsManageSubscription => 'Manage Subscription';

  @override
  String get subscriptionActive => 'Active';

  @override
  String get subscriptionExpired => 'Expired';

  @override
  String get subscriptionCancelled => 'Cancelled';

  @override
  String get subscriptionTrial => 'Trial';

  @override
  String get subscriptionGracePeriod => 'Grace Period';

  @override
  String get forgotPasswordTitle => 'Forgot Password?';

  @override
  String get forgotPasswordDescription =>
      'Enter your email address and we\'ll send you a code to reset your password.';

  @override
  String get forgotPasswordEmailLabel => 'Email';

  @override
  String get forgotPasswordEmailHint => 'Enter your email address';

  @override
  String get forgotPasswordSendButton => 'Send Reset Code';

  @override
  String get forgotPasswordInfoMock =>
      'In mock mode, the reset code is: 123456';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String resetPasswordDescription(String email) {
    return 'Enter the verification code sent to $email and your new password.';
  }

  @override
  String get resetPasswordCodeLabel => 'Verification Code';

  @override
  String get resetPasswordCodeHint => 'Enter 6-digit code';

  @override
  String get resetPasswordNewPasswordLabel => 'New Password';

  @override
  String get resetPasswordNewPasswordHint => 'Enter new password';

  @override
  String get resetPasswordConfirmLabel => 'Confirm Password';

  @override
  String get resetPasswordConfirmHint => 'Re-enter new password';

  @override
  String get resetPasswordButton => 'Reset Password';

  @override
  String get resetPasswordSuccess =>
      'Password reset successful! Please login with your new password.';

  @override
  String get resetPasswordCodeError => 'Please enter the verification code';

  @override
  String get resetPasswordCodeLengthError => 'Code must be 6 digits';

  @override
  String get resetPasswordCodeFormatError => 'Code must contain only numbers';

  @override
  String get resetPasswordNewPasswordError => 'Please enter a password';

  @override
  String get resetPasswordLengthError =>
      'Password must be at least 8 characters';

  @override
  String get resetPasswordNumberError =>
      'Password must contain at least one number';

  @override
  String get resetPasswordSpecialCharError =>
      'Password must contain at least one special character';

  @override
  String get resetPasswordConfirmError => 'Please confirm your password';

  @override
  String get resetPasswordMatchError => 'Passwords do not match';

  @override
  String get forgotPasswordButton => 'Forgot Password?';
}
