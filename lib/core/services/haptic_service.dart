import 'dart:io';
import 'package:flutter/services.dart';

/// Haptic feedback service following Apple HIG guidelines
/// Provides iOS-native haptic feedback for different interaction types
class HapticService {
  HapticService._();

  /// Light impact - Use for subtle UI changes
  /// iOS: UIImpactFeedbackGenerator with .light style
  static Future<void> lightImpact() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await HapticFeedback.lightImpact();
    }
  }

  /// Medium impact - Use for standard button taps
  /// iOS: UIImpactFeedbackGenerator with .medium style
  static Future<void> mediumImpact() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Heavy impact - Use for significant actions
  /// iOS: UIImpactFeedbackGenerator with .heavy style
  static Future<void> heavyImpact() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await HapticFeedback.heavyImpact();
    }
  }

  /// Selection change - Use for picker/selection changes
  /// iOS: UISelectionFeedbackGenerator
  static Future<void> selectionClick() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await HapticFeedback.selectionClick();
    }
  }

  /// Success notification - Use when an action completes successfully
  /// iOS: UINotificationFeedbackGenerator with .success type
  static Future<void> success() async {
    if (Platform.isIOS) {
      // iOS has specific notification feedback
      await HapticFeedback.mediumImpact();
    } else if (Platform.isAndroid) {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Warning notification - Use when user needs attention
  /// iOS: UINotificationFeedbackGenerator with .warning type
  static Future<void> warning() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await HapticFeedback.heavyImpact();
    }
  }

  /// Error notification - Use when an action fails
  /// iOS: UINotificationFeedbackGenerator with .error type
  static Future<void> error() async {
    if (Platform.isIOS || Platform.isAndroid) {
      // Double vibration for error
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    }
  }

  /// Button tap - Standard haptic for button presses
  /// Use this for most interactive elements
  static Future<void> buttonTap() async {
    await lightImpact();
  }

  /// Toggle - Use for switch/toggle state changes
  static Future<void> toggle() async {
    await mediumImpact();
  }

  /// Tab change - Use for bottom navigation tab switches
  static Future<void> tabChange() async {
    await selectionClick();
  }

  /// Pull to refresh - Use when pull-to-refresh threshold is reached
  static Future<void> pullToRefresh() async {
    await mediumImpact();
  }

  /// Swipe action - Use for swipe-to-delete or similar actions
  static Future<void> swipeAction() async {
    await mediumImpact();
  }

  /// Long press - Use when long press is detected
  static Future<void> longPress() async {
    await heavyImpact();
  }
}
