import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../providers/auth_providers.dart';

/// Screen for verifying reset code and setting new password
class VerifyResetCodeScreen extends ConsumerStatefulWidget {
  const VerifyResetCodeScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyResetCodeScreen> createState() =>
      _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends ConsumerState<VerifyResetCodeScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // First verify the code
    final verifyResult = await ref
        .read(authRepositoryProvider)
        .verifyPasswordResetCode(
          email: widget.email,
          code: _codeController.text.trim(),
        );

    if (!mounted) return;

    final verifyFailure = verifyResult.fold((failure) => failure, (_) => null);

    if (verifyFailure != null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(verifyFailure.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // If verification successful, reset the password
    final resetResult = await ref
        .read(authRepositoryProvider)
        .resetPassword(
          email: widget.email,
          code: _codeController.text.trim(),
          newPassword: _passwordController.text,
        );

    if (!mounted) return;

    setState(() => _isLoading = false);

    resetResult.fold(
      (failure) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (_) {
        // Success - show success message and navigate to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password reset successful! Please login with your new password.',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back to login screen
        context.go('/login');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GradientBackground(
        glowPosition: Alignment.topCenter,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => context.pop(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Header
                  _buildHeader(),

                  const SizedBox(height: 48),

                  // Code field
                  AppTextField(
                    controller: _codeController,
                    label: 'Verification Code',
                    hintText: 'Enter 6-digit code',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the verification code';
                      }
                      if (value.length != 6) {
                        return 'Code must be 6 digits';
                      }
                      if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                        return 'Code must contain only numbers';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // New password field
                  AppTextField(
                    controller: _passwordController,
                    label: 'New Password',
                    hintText: 'Enter new password',
                    obscureText: !_isPasswordVisible,
                    textInputAction: TextInputAction.next,
                    enabled: !_isLoading,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return 'Password must contain at least one number';
                      }
                      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                        return 'Password must contain at least one special character';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Confirm password field
                  AppTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hintText: 'Re-enter new password',
                    obscureText: !_isConfirmPasswordVisible,
                    textInputAction: TextInputAction.done,
                    enabled: !_isLoading,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onSubmitted: (_) => _resetPassword(),
                  ),

                  const SizedBox(height: 32),

                  // Reset button
                  AppButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    label: 'Reset Password',
                  ),

                  const SizedBox(height: 24),

                  // Info text
                  _buildInfoText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reset Password',
          style: AppTypography.displayLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter the verification code sent to ${widget.email} and your new password.',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'In mock mode, use code: 123456',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
