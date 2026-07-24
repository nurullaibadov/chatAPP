import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../domain/providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authNotifierProvider.notifier)
        .sendPasswordResetEmail(_emailController.text);

    if (!mounted) return;
    if (success) {
      SnackBarUtils.showSuccess(
        context,
        'Password reset link has been sent to your email!',
      );
      context.pop();
    } else {
      final error = ref.read(authNotifierProvider).errorMessage;
      if (error != null) {
        SnackBarUtils.showError(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Forgot Password?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email address below and we will send you instructions to reset your password.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightTextSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'Email Address',
                  hint: 'enter registered email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Send Reset Link',
                  isLoading: authState.isLoading,
                  onPressed: _handleReset,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
