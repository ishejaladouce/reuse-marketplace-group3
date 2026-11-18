import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';

/// First screen: introduces the app and leads to sign up or login.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('R',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  Text('Reuse',
                      style: textTheme.titleLarge?.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                height: 260,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.chair_outlined, size: 96, color: AppColors.primary),
              ),
              const SizedBox(height: 28),
              Text('A COMMUNITY MARKETPLACE',
                  style: textTheme.labelMedium?.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Text('Give good things a second home.',
                  style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.textDark, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('Buy and sell pre-loved items in your community, with more confidence.',
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => context.push('/signup'),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text('Get started'), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 18)],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/login'),
                  child: const Text('I already have an account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}