import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/auth_provider.dart';

/// Asks new users to confirm their email before using the app.
class EmailVerificationScreen extends ConsumerWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(authControllerProvider.notifier);
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final email = ref.watch(authRepositoryProvider).currentUser?.email ?? 'your email';
    final textTheme = Theme.of(context).textTheme;

    void showMessage(String message) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }

    Future<void> checkVerified() async {
      await controller.reloadUser();
      if (!context.mounted) return;
      final verified = ref.read(authRepositoryProvider).currentUser?.emailVerified ?? false;
      if (verified) {
        GoRouter.of(context).refresh();
      } else {
        showMessage('Your email is not verified yet. Please check your inbox and spam folder.');
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.mark_email_unread_outlined, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              Text('Verify your email',
                  style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text(
                'We sent a verification link to $email. Open it, then tap the button below.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: isLoading ? null : checkVerified,
                  child: const Text("I've verified my email"),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final sent = await controller.resendVerificationEmail();
                          if (!context.mounted) return;
                          showMessage(sent
                              ? 'Verification email sent again.'
                              : authErrorMessage(ref.read(authControllerProvider).error));
                        },
                  child: const Text('Resend email'),
                ),
              ),
              TextButton(
                onPressed: isLoading ? null : controller.signOut,
                child: const Text('Use a different account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}