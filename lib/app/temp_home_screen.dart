import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/providers/auth_provider.dart';

/// TEMPORARY home screen to test login.
class TempHomeScreen extends ConsumerWidget {
  const TempHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Reuse Marketplace')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Welcome, ${user?.displayName ?? user?.email ?? 'friend'}!'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
              child: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}