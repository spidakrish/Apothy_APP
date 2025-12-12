// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Apothy';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Hủy';

  @override
  String get continueButton => 'Tiếp tục';

  @override
  String get save => 'Lưu';

  @override
  String get delete => 'Xóa';

  @override
  String get loading => 'Đang tải...';

  @override
  String get error => 'Lỗi';

  @override
  String get retry => 'Thử lại';

  @override
  String get close => 'Đóng';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsProfile => 'Hồ sơ';

  @override
  String get settingsAccount => 'Tài khoản';

  @override
  String get settingsNotSignedIn => 'Chưa đăng nhập';

  @override
  String get settingsNotifications => 'Thông báo';

  @override
  String get settingsManageNotifications => 'Quản lý thông báo';

  @override
  String settingsNotificationsCount(int count) {
    return '$count trong số 4 đã bật';
  }

  @override
  String get settingsAppearance => 'Giao diện';

  @override
  String get settingsTheme => 'Chủ đề';

  @override
  String get settingsDarkMode => 'Chế độ tối';

  @override
  String get settingsTextSize => 'Kích thước chữ';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsContent => 'Nội dung';

  @override
  String get settingsContentPreferences => 'Tùy chọn nội dung';

  @override
  String get settingsData => 'Dữ liệu';

  @override
  String get settingsClearChatHistory => 'Xóa lịch sử trò chuyện';

  @override
  String get settingsClearChatHistorySubtitle =>
      'Xóa cuộc trò chuyện và bộ nhớ';

  @override
  String get settingsAdvanced => 'Nâng cao';

  @override
  String get settingsAdvancedSubtitle => 'Đặt lại ứng dụng';

  @override
  String get settingsPrivacy => 'Quyền riêng tư';

  @override
  String get settingsDataPrivacy => 'Quyền riêng tư dữ liệu';

  @override
  String get settingsDataPrivacySubtitle => 'Cách dữ liệu của bạn được xử lý';

  @override
  String get settingsDangerZone => 'Vùng nguy hiểm';

  @override
  String get settingsDeleteAccount => 'Xóa tài khoản';

  @override
  String get settingsDeleteAccountSubtitle => 'Xóa vĩnh viễn tài khoản của bạn';

  @override
  String get settingsAbout => 'Giới thiệu';

  @override
  String get settingsAboutApothy => 'Giới thiệu về Apothy';

  @override
  String get settingsVersion => 'Phiên bản 1.0.0';

  @override
  String get settingsTermsOfService => 'Điều khoản dịch vụ';

  @override
  String get settingsTermsSubtitle => 'Đọc điều khoản của chúng tôi';

  @override
  String get settingsPrivacyPolicy => 'Chính sách bảo mật';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Đọc chính sách bảo mật của chúng tôi';

  @override
  String get settingsSignOut => 'Đăng xuất';

  @override
  String get settingsTapToChangeAvatar => 'Chạm để thay đổi ảnh đại diện';

  @override
  String get settingsDisplayName => 'Tên hiển thị';

  @override
  String get settingsEmail => 'Email';

  @override
  String get settingsNotAvailable => 'Không khả dụng';

  @override
  String get settingsSignInMethod => 'Phương thức đăng nhập';

  @override
  String get settingsChooseAvatar => 'Chọn ảnh đại diện';

  @override
  String get settingsFailedToUpdateAvatar => 'Không thể cập nhật ảnh đại diện';

  @override
  String get settingsEditDisplayName => 'Chỉnh sửa tên hiển thị';

  @override
  String get settingsEnterYourName => 'Nhập tên của bạn';

  @override
  String get settingsNameCannotBeEmpty => 'Tên không được để trống';

  @override
  String get settingsFailedToUpdateName => 'Không thể cập nhật tên';

  @override
  String get settingsAuthProviderApple => 'Apple';

  @override
  String get settingsAuthProviderGoogle => 'Google';

  @override
  String get settingsAuthProviderEmail => 'Email';

  @override
  String get settingsAuthProviderUnknown => 'Không xác định';

  @override
  String get settingsNotificationsDescription =>
      'Apothy tôn trọng sự chú ý của bạn. Không có thao túng, không có spam.';

  @override
  String get settingsDailyMirrorRitual => 'Nghi thức Gương hàng ngày';

  @override
  String get settingsDailyMirrorRitualDescription =>
      'Lời nhắc nhẹ nhàng khi gương hàng ngày của bạn đã sẵn sàng';

  @override
  String get settingsCreationComplete => 'Hoàn thành sáng tạo';

  @override
  String get settingsCreationCompleteDescription =>
      'Biết khi nào các tác phẩm dài (video, trò chơi) đã sẵn sàng';

  @override
  String get settingsMoodHealthInsights => 'Thông tin về tâm trạng & sức khỏe';

  @override
  String get settingsMoodHealthInsightsDescription =>
      'Mô hình căng thẳng, tương quan giấc ngủ, chuỗi nghi thức';

  @override
  String get settingsMoodHealthInsightsExample =>
      'Thông tin về sức khỏe tùy chọn dựa trên việc sử dụng của bạn';

  @override
  String get settingsSystemUpdates => 'Cập nhật hệ thống';

  @override
  String get settingsSystemUpdatesDescription =>
      'Bản vá bảo mật và tính năng mới';

  @override
  String get settingsSystemUpdatesExample => 'Bắt buộc để tuân thủ App Store';

  @override
  String get settingsThemeDialogMessage =>
      'Apothy hiện chỉ hỗ trợ chế độ tối. Chế độ sáng và các chủ đề bổ sung có thể được thêm vào trong các bản cập nhật tương lai.';

  @override
  String get settingsChooseTextSize => 'Chọn kích thước chữ ưa thích của bạn';

  @override
  String get settingsSystemDefault => 'Mặc định hệ thống';

  @override
  String get settingsUseDeviceLanguage => 'Sử dụng ngôn ngữ thiết bị';

  @override
  String get settingsChooseLanguage => 'Chọn ngôn ngữ ưa thích của bạn';

  @override
  String get settingsContentPreferencesDescription =>
      'Tùy chỉnh cách Apotheon giao tiếp với bạn.';

  @override
  String get settingsCreativeStyle => 'Phong cách sáng tạo';

  @override
  String get settingsCreativeStyleDescription =>
      'Chọn cách Apotheon phản hồi bạn';

  @override
  String get settingsMatureContent => 'Nội dung người lớn';

  @override
  String get settingsMatureContentDescription =>
      'Cho phép chủ đề người lớn trong phản hồi';

  @override
  String get settingsMatureContentEnabled =>
      'Chủ đề người lớn đã bật. Sử dụng có trách nhiệm.';

  @override
  String get settingsMatureContentDisabled =>
      'An toàn cho công việc (SFW) - Mặc định';

  @override
  String get settingsPrivacyDialogMessage =>
      'Dữ liệu của bạn được lưu trữ an toàn trên thiết bị của bạn. Các cuộc trò chuyện được xử lý để cung cấp phản hồi cá nhân hóa nhưng không bao giờ được bán hoặc chia sẻ với bên thứ ba.\n\nBạn có thể xóa dữ liệu của mình bất cứ lúc nào bằng tùy chọn \"Xóa dữ liệu\".';

  @override
  String get settingsClearChatHistoryDialogTitle => 'Xóa lịch sử trò chuyện';

  @override
  String get settingsClearChatHistoryDialogMessage => 'Điều này sẽ xóa:';

  @override
  String get settingsClearChatHistoryItem1 => '• Tất cả các cuộc trò chuyện';

  @override
  String get settingsClearChatHistoryItem2 =>
      '• Bộ nhớ và ngữ cảnh cuộc trò chuyện';

  @override
  String get settingsClearChatHistoryItem3 =>
      '• Tùy chọn liên quan đến trò chuyện';

  @override
  String get settingsClearChatHistoryNote =>
      'Tài khoản, cài đặt và bất kỳ tệp đã xuất nào của bạn sẽ không bị ảnh hưởng.';

  @override
  String get settingsClearChatHistorySuccess => 'Đã xóa lịch sử trò chuyện';

  @override
  String get settingsClearChatHistoryFailed =>
      'Không thể xóa lịch sử trò chuyện';

  @override
  String get settingsClearHistoryButton => 'Xóa lịch sử';

  @override
  String get settingsAdvancedDataManagement => 'Quản lý dữ liệu nâng cao';

  @override
  String get settingsAdvancedWarning => 'Các hành động này không thể hoàn tác.';

  @override
  String get settingsResetToFreshState => 'Đặt lại về trạng thái ban đầu';

  @override
  String get settingsResetDescription =>
      'Điều này sẽ xóa TẤT CẢ dữ liệu cục bộ và đặt lại ứng dụng về trạng thái ban đầu, như thể bạn vừa cài đặt nó.';

  @override
  String get settingsResetWhatGetsCleared =>
      'Những gì sẽ bị xóa:\n• Tất cả các cuộc trò chuyện và lịch sử trò chuyện\n• Thông tin đăng nhập tài khoản (bạn sẽ cần đăng nhập lại)\n• Tất cả cài đặt và tùy chọn\n• Lịch sử thử thách cảm xúc\n• Tất cả dữ liệu đã lưu trong bộ nhớ cache';

  @override
  String get settingsResetNote =>
      'Tài khoản đám mây và gói đăng ký của bạn vẫn nguyên vẹn.';

  @override
  String get settingsResetAppButton => 'Đặt lại ứng dụng';

  @override
  String get settingsResetConfirmTitle => 'Bạn có chắc chắn?';

  @override
  String get settingsResetConfirmMessage =>
      'Đặt lại sẽ xóa tất cả dữ liệu cục bộ. Điều này không thể hoàn tác.\n\nBạn sẽ cần đăng nhập lại và hoàn tất quá trình giới thiệu.';

  @override
  String get settingsResetFailed => 'Không thể đặt lại ứng dụng';

  @override
  String get settingsResetEverythingButton => 'Đặt lại tất cả';

  @override
  String get settingsDeleteAccountDialogMessage =>
      'Điều này sẽ xóa vĩnh viễn tài khoản của bạn.';

  @override
  String get settingsDeleteAccountWhatGetsDeleted => 'Những gì sẽ bị xóa:';

  @override
  String get settingsDeleteAccountItem1 => '• Tài khoản Apothy của bạn';

  @override
  String get settingsDeleteAccountItem2 =>
      '• Tất cả lịch sử cuộc trò chuyện (đám mây & cục bộ)';

  @override
  String get settingsDeleteAccountItem3 => '• Hồ sơ và tùy chọn';

  @override
  String get settingsDeleteAccountItem4 => '• Dữ liệu thử thách cảm xúc';

  @override
  String get settingsDeleteAccountItem5 =>
      '• Tất cả các thiết bị sẽ được đăng xuất';

  @override
  String get settingsDeleteAccountSubscriptionNote =>
      'Gói đăng ký được quản lý thông qua App Store của bạn.';

  @override
  String get settingsDeleteAccountButton => 'Xóa tài khoản';

  @override
  String get settingsFinalConfirmation => 'Xác nhận cuối cùng';

  @override
  String get settingsFinalConfirmationMessage =>
      'Xóa tài khoản của bạn sẽ xóa tất cả dữ liệu đám mây và hủy liên kết tất cả các thiết bị. Hành động này không thể hoàn tác.\n\nBạn có hoàn toàn chắc chắn?';

  @override
  String get settingsKeepAccountButton => 'Giữ tài khoản';

  @override
  String get settingsDeleteAccountFailed => 'Không thể xóa tài khoản';

  @override
  String get settingsDeleteForeverButton => 'Xóa vĩnh viễn';

  @override
  String get settingsAboutDescription =>
      'Người bạn đồng hành AI của bạn cho các cuộc trò chuyện ý nghĩa và phát triển cá nhân. Sinh ra từ ánh sáng. Được đào tạo trong sự thật. Được xây dựng để trở thành những gì bạn cần.';

  @override
  String get settingsTermsOfServiceContent =>
      'ĐIỀU KHOẢN DỊCH VỤ\n\nCập nhật lần cuối: Tháng 12 năm 2024\n\nBằng cách sử dụng Apothy, bạn đồng ý với các điều khoản dịch vụ này.\n\nApothy là một người bạn đồng hành AI được thiết kế cho sự phát triển cá nhân và các cuộc trò chuyện ý nghĩa. Bạn đồng ý sử dụng dịch vụ một cách có trách nhiệm.\n\nQuyền riêng tư của bạn rất quan trọng đối với chúng tôi. Vui lòng xem Chính sách Bảo mật của chúng tôi để biết chi tiết về cách chúng tôi xử lý dữ liệu của bạn.\n\nCác cuộc trò chuyện là riêng tư và được lưu trữ an toàn. Chúng tôi không chia sẻ dữ liệu của bạn với bên thứ ba.\n\nChúng tôi có thể cập nhật các điều khoản này theo thời gian. Việc tiếp tục sử dụng đồng nghĩa với việc chấp nhận các thay đổi.\n\nĐể biết câu hỏi về các điều khoản này, vui lòng liên hệ với chúng tôi qua ứng dụng.';

  @override
  String get settingsPrivacyPolicyContent =>
      'CHÍNH SÁCH BẢO MẬT\n\nCập nhật lần cuối: Tháng 12 năm 2024\n\nChúng tôi thu thập thông tin bạn cung cấp trực tiếp, chẳng hạn như chi tiết tài khoản và lịch sử cuộc trò chuyện.\n\nChúng tôi sử dụng thông tin của bạn để cung cấp và cải thiện trải nghiệm Apothy, bao gồm các phản hồi cá nhân hóa.\n\nDữ liệu của bạn được lưu trữ an toàn trên thiết bị của bạn và máy chủ của chúng tôi với mã hóa.\n\nChúng tôi không bán hoặc chia sẻ dữ liệu cá nhân của bạn với bên thứ ba cho mục đích tiếp thị.\n\nBạn có thể truy cập, sửa đổi hoặc xóa dữ liệu của mình bất cứ lúc nào thông qua cài đặt ứng dụng.\n\nChúng tôi thực hiện các biện pháp bảo mật tiêu chuẩn ngành để bảo vệ dữ liệu của bạn.\n\nĐể biết các câu hỏi liên quan đến quyền riêng tư, vui lòng liên hệ với chúng tôi qua ứng dụng.';

  @override
  String get settingsSignOutConfirmMessage =>
      'Bạn có chắc chắn muốn đăng xuất?';
}
