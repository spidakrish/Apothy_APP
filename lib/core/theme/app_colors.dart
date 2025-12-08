import 'package:flutter/material.dart';

/// Apothy app colour palette
/// Based on Figma design specifications
class AppColors {
  AppColors._();

  // ============================================================================
  // Primary Colours
  // ============================================================================

  /// Primary purple/violet accent colour
  static const Color primary = Color(0xFF8B5CF6);

  /// Primary colour variants
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF7C3AED);

  // ============================================================================
  // Background Colours
  // ============================================================================

  /// Main dark background
  static const Color background = Color(0xFF0A0A0F);

  /// Slightly lighter background for cards/surfaces
  static const Color surface = Color(0xFF1A1A1F);

  /// Card background colour
  static const Color cardBackground = Color(0xFF1F1F24);

  /// Input field background
  static const Color inputBackground = Color(0xFF2A2A30);

  // ============================================================================
  // Text Colours
  // ============================================================================

  /// Primary text colour (white)
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text colour (gray)
  static const Color textSecondary = Color(0xFF9CA3AF);

  /// Tertiary text colour (darker gray)
  static const Color textTertiary = Color(0xFF6B7280);

  /// Disabled text colour
  static const Color textDisabled = Color(0xFF4B5563);

  // ============================================================================
  // Message Bubble Colours
  // ============================================================================

  /// User message bubble background
  static const Color userBubble = Color(0xFF8B5CF6);

  /// User message bubble text
  static const Color userBubbleText = Color(0xFFFFFFFF);

  /// Assistant message bubble background
  static const Color assistantBubble = Color(0xFF2A2A30);

  /// Assistant message bubble text
  static const Color assistantBubbleText = Color(0xFFFFFFFF);

  // ============================================================================
  // Border Colours
  // ============================================================================

  /// Default border colour
  static const Color border = Color(0xFF374151);

  /// Subtle border colour
  static const Color borderSubtle = Color(0xFF1F2937);

  /// Focused border colour
  static const Color borderFocused = Color(0xFF8B5CF6);

  // ============================================================================
  // Status Colours
  // ============================================================================

  /// Success colour (green)
  static const Color success = Color(0xFF10B981);

  /// Warning colour (amber)
  static const Color warning = Color(0xFFF59E0B);

  /// Error colour (red)
  static const Color error = Color(0xFFEF4444);

  /// Info colour (blue)
  static const Color info = Color(0xFF3B82F6);

  // ============================================================================
  // Navigation
  // ============================================================================

  /// Navigation bar background
  static const Color navBarBackground = Color(0xFF0A0A0F);

  /// Navigation bar active icon colour
  static const Color navBarActive = Color(0xFF8B5CF6);

  /// Navigation bar inactive icon colour
  static const Color navBarInactive = Color(0xFF6B7280);

  // ============================================================================
  // Gradients
  // ============================================================================

  /// Primary gradient for buttons and accents
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8B5CF6),
      Color(0xFF7C3AED),
    ],
  );

  /// Background gradient with purple glow effect
  static const RadialGradient backgroundGlow = RadialGradient(
    center: Alignment.center,
    radius: 1.0,
    colors: [
      Color(0xFF1A1025), // Subtle purple tint
      Color(0xFF0A0A0F), // Dark background
    ],
  );

  // ============================================================================
  // Shadows
  // ============================================================================

  /// Primary shadow for elevated elements
  static List<BoxShadow> get primaryShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  /// Subtle shadow for cards
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];
}
