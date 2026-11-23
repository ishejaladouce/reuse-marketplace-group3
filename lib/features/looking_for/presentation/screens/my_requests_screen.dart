
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../listings/presentation/providers/looking_for_providers.dart';
import 'create_edit_request_screen.dart';
import 'looking_for_screen.dart';

class MyRequestsScreen extends ConsumerWidget {
  const MyRequestsScreen({super.key});

  Future<void> _deleteRequest(
    BuildContext context,
    WidgetRef ref,
    String requestId,
    String userId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete request?'),
        content: const Text(
          'This request will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(lookingForRepositoryProvider)
          .deleteRequest(requestId);

      if (!context.mounted) return;

      ref.invalidate(userLookingForRequestsProvider(userId));
      ref.invalidate(openLookingForRequestsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request deleted.')),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Requests')),
        body: const Center(
          child: Text('Please sign in to view your requests.'),
        ),
      );
    }

    final requestsAsync = ref.watch(
      userLookingForRequestsProvider(user.uid),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('My Requests')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateEditRequestScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
      body: requestsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Could not load requests: $error'),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(
              child: Text('You have not posted any requests yet.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];

              return Column(
                children: [
                  LookingForRequestCard(request: request),
                  Row(
                    children: [
                      Chip(
                        label: Text(request.status.toUpperCase()),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateEditRequestScreen(
                                request: request,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                      ),
                      TextButton.icon(
                        onPressed: () => _deleteRequest(
                          context,
                          ref,
                          request.id,
                          user.uid,
                        ),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete'),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
