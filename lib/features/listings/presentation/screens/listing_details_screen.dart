
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../chat/presentation/providers/chat_providers.dart';
import '../../../../screens/chat_screen.dart';
import '../providers/listing_providers.dart';

class ListingDetailsScreen extends ConsumerStatefulWidget {
  final String listingId;

  const ListingDetailsScreen({
    super.key,
    required this.listingId,
  });

  @override
  ConsumerState<ListingDetailsScreen> createState() =>
      _ListingDetailsScreenState();
}

class _ListingDetailsScreenState
    extends ConsumerState<ListingDetailsScreen> {
  bool _openingChat = false;

  Future<void> _contactSeller() async {
    if (_openingChat) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to contact the seller.'),
        ),
      );
      return;
    }

    setState(() => _openingChat = true);

    try {
      final conversationId = await ref
          .read(chatControllerProvider)
          .startConversation(widget.listingId);

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversationId,
          ),
        ),
      );
    } catch (error, stackTrace) {
  debugPrint('CHAT ERROR: $error');
  debugPrintStack(stackTrace: stackTrace);

  if (!mounted) return;

 final messenger = ScaffoldMessenger.maybeOf(context);

  messenger?.showSnackBar(
    SnackBar(
      content: Text('Unable to open chat: $error'),
    ),
  );
}finally {
      if (mounted) {
        setState(() => _openingChat = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(
      listingDetailsProvider(widget.listingId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Item details')),
      body: listingAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Unable to load item: $error'),
        ),
        data: (listing) {
          if (listing == null) {
            return const Center(
              child: Text('This listing is no longer available.'),
            );
          }

          final theme = Theme.of(context);
          final currentUserId =
              FirebaseAuth.instance.currentUser?.uid;
          final isOwner = currentUserId == listing.sellerId;

          return ListView(
            children: [
              SizedBox(
                height: 300,
                child: listing.imageUrls.isEmpty
                    ? Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(
                          Icons.image_outlined,
                          size: 80,
                        ),
                      )
                    : PageView.builder(
                        itemCount: listing.imageUrls.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            listing.imageUrls[index],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style:
                          theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${listing.currency} ${listing.price.toStringAsFixed(0)}',
                      style:
                          theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text(listing.category)),
                        Chip(label: Text(listing.condition)),
                        Chip(label: Text(listing.status)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Description',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(listing.description),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(listing.location),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            listing.deliveryAvailable
                                ? 'Delivery available'
                                : 'Delivery unavailable',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.storefront_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            listing.pickupAvailable
                                ? 'Pickup available'
                                : 'Pickup unavailable',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: isOwner || _openingChat
                            ? null
                            : _contactSeller,
                        icon: _openingChat
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                isOwner
                                    ? Icons.person_outline
                                    : Icons.chat_bubble_outline,
                              ),
                        label: Text(
                          isOwner
                              ? 'Your listing'
                              : _openingChat
                                  ? 'Opening chat...'
                                  : 'Contact seller',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
