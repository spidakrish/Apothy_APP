import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Reusable text field widget matching Apothy design system
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.label,
    this.labelText,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.autofocus = false,
    this.validator,
  });

  /// Text editing controller
  final TextEditingController? controller;

  /// Placeholder text
  final String? hintText;

  /// Label text above the field (alias for labelText)
  final String? label;

  /// Label text above the field
  final String? labelText;

  /// Error message to display
  final String? errorText;

  /// Whether to obscure text (for passwords)
  final bool obscureText;

  /// Whether the field is enabled
  final bool enabled;

  /// Maximum number of lines
  final int maxLines;

  /// Minimum number of lines
  final int? minLines;

  /// Maximum character length
  final int? maxLength;

  /// Keyboard type
  final TextInputType? keyboardType;

  /// Text input action
  final TextInputAction? textInputAction;

  /// Called when text changes
  final ValueChanged<String>? onChanged;

  /// Called when user submits
  final ValueChanged<String>? onSubmitted;

  /// Leading icon
  final Widget? prefixIcon;

  /// Trailing icon
  final Widget? suffixIcon;

  /// Focus node
  final FocusNode? focusNode;

  /// Whether to autofocus
  final bool autofocus;

  /// Form field validator
  final String? Function(String?)? validator;

  /// Gets the effective label (supports both label and labelText)
  String? get _effectiveLabel => label ?? labelText;

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      hintText: hintText,
      hintStyle: AppTypography.inputPlaceholder,
      errorText: errorText,
      errorStyle: AppTypography.bodySmall.copyWith(
        color: AppColors.error,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.inputBackground,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderFocused),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
    );

    final textStyle = AppTypography.bodyMedium.copyWith(
      color: AppColors.textPrimary,
    );

    // Use TextFormField when validator is provided, otherwise use TextField
    final Widget inputField = validator != null
        ? TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            enabled: enabled,
            maxLines: maxLines,
            minLines: minLines,
            maxLength: maxLength,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onChanged: onChanged,
            onFieldSubmitted: onSubmitted,
            autofocus: autofocus,
            style: textStyle,
            cursorColor: AppColors.primary,
            decoration: inputDecoration,
            validator: validator,
          )
        : TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            enabled: enabled,
            maxLines: maxLines,
            minLines: minLines,
            maxLength: maxLength,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            autofocus: autofocus,
            style: textStyle,
            cursorColor: AppColors.primary,
            decoration: inputDecoration,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_effectiveLabel != null) ...[
          Text(
            _effectiveLabel!,
            style: AppTypography.labelMedium,
          ),
          const SizedBox(height: 8),
        ],
        inputField,
      ],
    );
  }
}

/// Specialized chat input field with send button
class ChatInputField extends StatelessWidget {
  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText = 'Type a message...',
    this.enabled = true,
    this.focusNode,
  });

  /// Text editing controller
  final TextEditingController controller;

  /// Called when user sends a message
  final VoidCallback onSend;

  /// Placeholder text
  final String hintText;

  /// Whether the field is enabled
  final bool enabled;

  /// Focus node
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              maxLines: 4,
              minLines: 1,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTypography.inputPlaceholder,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          IconButton(
            onPressed: enabled ? onSend : null,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
