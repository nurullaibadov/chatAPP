import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../domain/providers/auth_provider.dart';
import '../router/app_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).signUp(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) return;
    if (success) {
      context.go(AppRoutes.profileSetup);
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
        title: const Text('Create Account'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Join ChatApp',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect with people around the world seamlessly',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightTextSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'e.g. Alex Johnson',
                    controller: _nameController,
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                    validator: (val) => Validators.validateRequired(val, 'Name'),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Email',
                    hint: 'enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Password',
                    hint: 'enter password (min 6 chars)',
                    controller: _passwordController,
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: 're-enter password',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock_reset, size: 20),
                    validator: (val) => Validators.validateConfirmPassword(
                        val, _passwordController.text),
                  ),
                  const SizedBox(height: 28),
                  CustomButton(
                    text: 'Create Account',
                    isLoading: authState.isLoading,
                    onPressed: _handleRegister,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? '),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
