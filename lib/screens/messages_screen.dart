
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/chat/data/models/conversation_model.dart';
import '../features/chat/presentation/providers/chat_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'chat_screen.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() =>
      _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  int tab = 0; // 0 = All, 1 = Buying, 2 = Selling
  String searchQuery = '';
  bool showSearch = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: Icon(showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                showSearch = !showSearch;
                if (!showSearch) searchQuery = '';
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search conversations',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() => searchQuery = value.toLowerCase());
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Segmented(
              options: const ['All', 'Buying', 'Selling'],
              selected: tab,
              onChanged: (index) {
                setState(() => tab = index);
              },
            ),
          ),

          Expanded(
            child: conversationsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => _buildError(error),
              data: (conversations) {
                if (user == null) {
                  return const Center(
                    child: Text('Please sign in to view messages.'),
                  );
                }

                final filtered = conversations.where((conversation) {
                  final isBuying =
                      conversation.isBuying(user.uid);

                  final matchesTab =
                      tab == 0 ||
                      (tab == 1 && isBuying) ||
                      (tab == 2 && !isBuying);

                  final query = searchQuery.trim();

                  final matchesSearch =
                      query.isEmpty ||
                      conversation.listingTitle
                          .toLowerCase()
                          .contains(query) ||
                      conversation.lastMessage
                          .toLowerCase()
                          .contains(query);

                  return matchesTab && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'No conversations yet',
                    body:
                        'Message a seller from any listing to start chatting.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(conversationsProvider);
                    await ref.read(
                      conversationsProvider.future,
                    );
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final conversation = filtered[index];

                      return _ConversationTile(
                        conversation: conversation,
                        currentUserId: user.uid,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 42,
              color: AppColors.muted,
            ),
            const SizedBox(height: 12),
            const Text(
              'Could not load conversations',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                ref.invalidate(conversationsProvider);
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final String currentUserId;

  const _ConversationTile({
    required this.conversation,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final otherUserId =
        conversation.otherParticipantId(currentUserId);

    final displayName =
        conversation.isBuying(currentUserId)
            ? 'Seller'
            : 'Buyer';

    final date = conversation.updatedAt;

    final time =
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: conversation.id,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Avatar(displayName),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    conversation.listingTitle,
                    style: const TextStyle(
                      color: AppColors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    conversation.lastMessage.isEmpty
                        ? 'Start the conversation'
                        : conversation.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.muted,
                  size: 18,
                  semanticLabel:
                      'Open conversation with $otherUserId',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
