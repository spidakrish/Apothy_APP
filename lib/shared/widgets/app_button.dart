import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Button variants available in the app
enum AppButtonVariant {
  /// Filled button with primary colour
  primary,

  /// Outlined button with border
  outlined,

  /// Text-only button
  text,
}

/// Reusable button widget matching Apothy design system
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
  });

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button label text
  final String label;

  /// Button style variant
  final AppButtonVariant variant;

  /// Shows loading indicator when true
  final bool isLoading;

  /// Enables/disables the button
  final bool isEnabled;

  /// Optional leading icon
  final IconData? icon;

  /// Optional fixed width
  final double? width;

  @override
  Widget build(BuildContext context) {
    final bool canPress = isEnabled && !isLoading && onPressed != null;

    return SizedBox(
      width: width,
      child: switch (variant) {
        AppButtonVariant.primary => _buildPrimaryButton(canPress),
        AppButtonVariant.outlined => _buildOutlinedButton(canPress),
        AppButtonVariant.text => _buildTextButton(canPress),
      },
    );
  }

  Widget _buildPrimaryButton(bool canPress) {
    return ElevatedButton(
      onPressed: canPress ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: canPress ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildOutlinedButton(bool canPress) {
    return OutlinedButton(
      onPressed: canPress ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: canPress ? AppColors.textPrimary : AppColors.textDisabled,
        side: BorderSide(
          color: canPress ? AppColors.border : AppColors.borderSubtle,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildTextButton(bool canPress) {
    return TextButton(
      onPressed: canPress ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: canPress ? AppColors.primary : AppColors.textDisabled,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label, style: AppTypography.labelLarge),
        ],
      );
    }

    return Text(label, style: AppTypography.labelLarge);
  }
}
