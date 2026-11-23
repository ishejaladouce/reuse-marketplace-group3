import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/auth/presentation/providers/auth_provider.dart';

/// Temporary home screen until the team's marketplace home is merged.
class TempHomeScreen extends ConsumerWidget {
  const TempHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).asData?.value;
    final name = user?.displayName ?? 'there';

    return Scaffold(
      appBar: AppBar(title: const Text('Reuse Marketplace')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Welcome, $name!', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.push('/profile'),
                icon: const Icon(Icons.person_outline),
                label: const Text('My profile'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push('/orders/test-order-1/review'),
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Test: review an order'),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}