import 'dart:io';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Apothy app typography styles
/// Uses platform-native fonts following Apple Human Interface Guidelines:
/// - SF Pro Display (CupertinoSystemDisplay) for sizes ≥20pt
/// - SF Pro Text (CupertinoSystemText) for sizes <20pt
/// - Roboto on Android
///
/// Text sizes follow Apple HIG exactly:
/// - Large Title: 34pt
/// - Title 1: 28pt, Title 2: 22pt, Title 3: 20pt
/// - Headline: 17pt (semi-bold), Body: 17pt, Callout: 16pt
/// - Subhead: 15pt, Footnote: 13pt
/// - Caption 1: 12pt, Caption 2: 11pt
/// - Tab Bar: 10pt
///
/// Letter spacing values are from Flutter's official CupertinoTextThemeData
/// (calibrated for Flutter's text rendering engine)
/// Source: https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/cupertino/text_theme.dart
class AppTypography {
  AppTypography._();

  // ============================================================================
  // Font Family Helpers - Apple HIG compliant
  // ============================================================================

  /// Font family for display sizes (≥20pt)
  /// Uses SF Pro Display on iOS/macOS, Roboto on Android
  static String? get _fontFamilyDisplay {
    if (Platform.isIOS || Platform.isMacOS) {
      return 'CupertinoSystemDisplay';
    }
    return 'Roboto';
  }

  /// Font family for text sizes (<20pt)
  /// Uses SF Pro Text on iOS/macOS, Roboto on Android
  static String? get _fontFamilyText {
    if (Platform.isIOS || Platform.isMacOS) {
      return 'CupertinoSystemText';
    }
    return 'Roboto';
  }

  // ============================================================================
  // Display Styles - Uses SF Pro Display (≥20pt)
  // ============================================================================

  /// Display Large - HIG Large Title (34pt)
  /// Used for main screen titles
  /// letterSpacing: 0.38 (from Flutter's navLargeTitleTextStyle)
  static TextStyle get displayLarge => TextStyle(
    fontFamily: _fontFamilyDisplay,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.38,
    color: AppColors.textPrimary,
  );

  /// Display Medium - HIG Large Title variant
  /// Used for prominent section titles
  static TextStyle get displayMedium => TextStyle(
    fontFamily: _fontFamilyDisplay,
    fontSize: 34,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
    color: AppColors.textPrimary,
  );

  /// Display Small - HIG Title 1 (28pt)
  /// Used for smaller section titles
  /// Interpolated letterSpacing between 34pt (0.38) and 20pt (-0.6)
  static TextStyle get displaySmall => TextStyle(
    fontFamily: _fontFamilyDisplay,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.03,
    color: AppColors.textPrimary,
  );

  /// Headline Large - HIG Title 1 (28pt)
  static TextStyle get headlineLarge => TextStyle(
    fontFamily: _fontFamilyDisplay,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.03,
    color: AppColors.textPrimary,
  );

  /// Headline Medium - HIG Title 2 (22pt)
  /// Interpolated letterSpacing
  static TextStyle get headlineMedium => TextStyle(
    fontFamily: _fontFamilyDisplay,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.43,
    color: AppColors.textPrimary,
  );

  /// Headline Small - HIG Title 3 (20pt)
  /// letterSpacing: -0.6 (from Flutter's pickerTextStyle at 21pt)
  static TextStyle get headlineSmall => TextStyle(
    fontFamily: _fontFamilyDisplay,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.6,
    color: AppColors.textPrimary,
  );

  // ============================================================================
  // Body Text - Uses SF Pro Text (<20pt)
  // ============================================================================

  /// Body Large - HIG Body (17pt)
  /// Primary content text
  /// letterSpacing: -0.41 (from Flutter's textStyle)
  static TextStyle get bodyLarge => TextStyle(
    fontFamily: _fontFamilyText,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.29,
    letterSpacing: -0.41,
    color: AppColors.textPrimary,
  );

  /// Body Medium - HIG Callout (16pt)
  /// Secondary content text
  /// letterSpacing interpolated between 17pt (-0.41) and 15pt
  static TextStyle get bodyMedium => TextStyle(
    fontFamily: _fontFamilyText,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.31,
    letterSpacing: -0.32,
    color: AppColors.textPrimary,
  );

  /// Body Small - HIG Subhead (15pt)
  /// Tertiary content text
  static TextStyle get bodySmall => TextStyle(
    fontFamily: _fontFamilyText,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: -0.23,
    color: AppColors.textSecondary,
  );

  // ============================================================================
  // Labels - Uses SF Pro Text (<20pt)
  // ============================================================================

  /// Label Large - HIG Headline (17pt semi-bold)
  /// Button text, important labels
  /// letterSpacing: -0.41 (from Flutter's textStyle)
  static TextStyle get labelLarge => TextStyle(
    fontFamily: _fontFamilyText,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    color: AppColors.textPrimary,
  );

  /// Label Medium - HIG Subhead (15pt)
  /// Standard labels
  static TextStyle get labelMedium => TextStyle(
    fontFamily: _fontFamilyText,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.23,
    color: AppColors.textSecondary,
  );

  /// Label Small - HIG Caption 1 (12pt)
  /// Small labels, captions
  static TextStyle get labelSmall => TextStyle(
    fontFamily: _fontFamilyText,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: AppColors.textTertiary,
  );

  // ============================================================================
  // Special Styles - HIG compliant
  // ============================================================================

  /// Chat message text style - HIG Body (17pt)
  /// letterSpacing: -0.41 (from Flutter's textStyle)
  static TextStyle get chatMessage => TextStyle(
    fontFamily: _fontFamilyText,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.29,
    letterSpacing: -0.41,
    color: AppColors.textPrimary,
  );

  /// Input placeholder text - HIG Body (17pt)
  static TextStyle get inputPlaceholder => TextStyle(
    fontFamily: _fontFamilyText,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    color: AppColors.textTertiary,
  );

  /// Navigation label text - HIG Tab Bar (10pt)
  /// letterSpacing: -0.24 (from Flutter's tabLabelTextStyle)
  static TextStyle get navLabel => TextStyle(
    fontFamily: _fontFamilyText,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.24,
    color: AppColors.navBarInactive,
  );

  /// Active navigation label text - HIG Tab Bar (10pt)
  static TextStyle get navLabelActive => TextStyle(
    fontFamily: _fontFamilyText,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.24,
    color: AppColors.navBarActive,
  );

  /// Timestamp text - HIG Caption 2 (11pt)
  static TextStyle get timestamp => TextStyle(
    fontFamily: _fontFamilyText,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textTertiary,
  );

  /// Badge/chip text - HIG Caption 1 (12pt)
  static TextStyle get badge => TextStyle(
    fontFamily: _fontFamilyText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Footnote text - HIG Footnote (13pt)
  static TextStyle get footnote => TextStyle(
    fontFamily: _fontFamilyText,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.38,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );
}
