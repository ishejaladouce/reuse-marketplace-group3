import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

/// Create Account screen
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _agreed = ValueNotifier<bool>(false);
  final _hidePassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _agreed.dispose();
    _hidePassword.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed.value) {
      _showMessage('Please agree to the Terms and Privacy Policy.');
      return;
    }
    final success = await ref.read(authControllerProvider.notifier).signUp(
          fullName: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phoneNumber: _phoneController.text,
        );
    if (!mounted) return;
    if (!success) {
      _showMessage(authErrorMessage(ref.read(authControllerProvider).error));
    }
    // On success, the router automatically opens the email verification screen.
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('WELCOME TO REUSE',
                    style: textTheme.labelMedium?.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Text('Create your account',
                    style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('One account to buy, sell and build your reputation.',
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Full name',
                  hint: 'Your full name',
                  controller: _nameController,
                  validator: Validators.fullName,
                  textCapitalization: TextCapitalization.words,
                ),
                AppTextField(
                  label: 'Phone number',
                  hint: '+250 7XX XXX XXX',
                  controller: _phoneController,
                  validator: Validators.phone,
                  keyboardType: TextInputType.phone,
                ),
                AppTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _emailController,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _hidePassword,
                  builder: (context, hidden, _) => Column(
                    children: [
                      AppTextField(
                        label: 'Password',
                        hint: 'At least 8 characters',
                        controller: _passwordController,
                        validator: Validators.password,
                        obscureText: hidden,
                        suffix: IconButton(
                          icon: Icon(hidden ? Icons.visibility_off : Icons.visibility),
                          tooltip: hidden ? 'Show password' : 'Hide password',
                          onPressed: () => _hidePassword.value = !hidden,
                        ),
                      ),
                      AppTextField(
                        label: 'Confirm password',
                        hint: 'Repeat password',
                        controller: _confirmController,
                        validator: (value) =>
                            Validators.confirmPassword(value, _passwordController.text),
                        obscureText: hidden,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _agreed,
                  builder: (context, agreed, _) => CheckboxListTile(
                    value: agreed,
                    onChanged: (value) => _agreed.value = value ?? false,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.primary,
                    title: const Text('I agree to the Terms and Privacy Policy'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Create account'),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_user_outlined, color: AppColors.primary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text('Your details are encrypted and never shared without permission.'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => context.pushReplacement('/login'),
                    child: const Text('Already have an account? Log in'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}