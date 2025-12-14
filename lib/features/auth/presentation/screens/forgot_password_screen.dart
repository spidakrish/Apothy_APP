import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../providers/auth_providers.dart';

/// Screen for requesting password reset code
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await ref
        .read(authRepositoryProvider)
        .sendPasswordResetCode(email: _emailController.text.trim());

    if (!mounted) return;

    setState(() => _isLoading = false);

    result.fold(
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
        // Success - navigate to verification screen
        context.push('/verify-reset-code', extra: _emailController.text.trim());
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

                  // Email field
                  AppTextField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Enter your email address',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onSubmitted: (_) => _sendResetCode(),
                  ),

                  const SizedBox(height: 32),

                  // Send code button
                  AppButton(
                    onPressed: _isLoading ? null : _sendResetCode,
                    label: 'Send Reset Code',
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
          'Forgot Password?',
          style: AppTypography.displayLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter your email address and we\'ll send you a code to reset your password.',
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
              'In mock mode, the reset code is: 123456',
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
