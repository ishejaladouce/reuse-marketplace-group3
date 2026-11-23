
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/chat/data/models/chat_message_model.dart';
import '../features/chat/presentation/providers/chat_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'checkout_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({
    super.key,
    required this.conversationId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  bool _sending = false;
  int _lastMessageCount = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;

      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();

    if (text.isEmpty || _sending) return;

    if (text.length > 2000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Messages cannot exceed 2000 characters.'),
        ),
      );
      return;
    }

    setState(() => _sending = true);

    try {
      await ref.read(chatControllerProvider).sendMessage(
            conversationId: widget.conversationId,
            text: text,
          );

      if (!mounted) return;

      _ctrl.clear();
      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not send message: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in to use Chat.'),
        ),
      );
    }

    final conversationAsync = ref.watch(
      conversationProvider(widget.conversationId),
    );

    final messagesAsync = ref.watch(
      chatMessagesProvider(widget.conversationId),
    );

    return conversationAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: _buildError(
          'Could not load conversation',
          error,
        ),
      ),
      data: (conversation) {
        if (conversation == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chat')),
            body: const Center(
              child: Text('Conversation not found.'),
            ),
          );
        }

        final isBuying = conversation.isBuying(currentUser.uid);
        final otherPerson = isBuying ? 'Seller' : 'Buyer';

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Row(
              children: [
                Avatar(otherPerson, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherPerson,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        conversation.listingTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              if (isBuying)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16, 0, 16, 8,
                  ),
                  child: AppCard(
                    color: AppColors.mint,
                   
onTap: () async {
  try {
    final listingDoc = await FirebaseFirestore.instance
        .collection('listings')
        .doc(conversation.listingId)
        .get();

    if (!context.mounted) return;

    if (!listingDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This listing is no longer available.'),
        ),
      );
      return;
    }

    final listingData = listingDoc.data()!;

    final price = (listingData['price'] as num?)?.toInt();

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This listing has an invalid price.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          listingId: conversation.listingId,
          sellerId: conversation.sellerId,
          itemName: conversation.listingTitle,
          price: price,
        ),
      ),
    );
  } catch (error) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not load listing: $error'),
      ),
    );
  }
},

                    child: const Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: AppColors.green,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Agreed on a price? Pay in Reuse so your money is held until the item arrives.',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.green,
                        ),
                      ],
                    ),
                  ),
                ),

              Expanded(
                child: messagesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => _buildError(
                    'Could not load messages',
                    error,
                  ),
                  data: (messages) {
                    if (messages.length != _lastMessageCount) {
                      _lastMessageCount = messages.length;
                      _scrollToBottom();
                    }

                    if (messages.isEmpty) {
                      return const EmptyState(
                        icon: Icons.chat_bubble_outline,
                        title: 'Start the conversation',
                        body:
                            'Say hello and ask about the item!',
                      );
                    }

                    return ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(
                        16, 8, 16, 8,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (_, index) {
                        final message = messages[index];

                        return _buildMessageBubble(
                          message,
                          currentUser.uid,
                        );
                      },
                    );
                  },
                ),
              ),

              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    12, 6, 12, 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          enabled: !_sending,
                          minLines: 1,
                          maxLines: 4,
                          textCapitalization:
                              TextCapitalization.sentences,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: const InputDecoration(
                            hintText: 'Write a message',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.green,
                          minimumSize: const Size(48, 48),
                        ),
                        onPressed: _sending ? null : _send,
                        icon: _sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(
    ChatMessageModel message,
    String currentUserId,
  ) {
    final mine = message.isMine(currentUserId);

    return Align(
      alignment:
          mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: mine ? AppColors.green : Colors.white,
          border: mine
              ? null
              : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: mine ? Colors.white : AppColors.ink,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                fontSize: 10,
                color:
                    mine ? Colors.white70 : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String title, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.muted,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
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
                ref.invalidate(
                  conversationProvider(widget.conversationId),
                );
                ref.invalidate(
                  chatMessagesProvider(widget.conversationId),
                );
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
