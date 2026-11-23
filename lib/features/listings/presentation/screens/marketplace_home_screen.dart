
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/listing_providers.dart';
import '../widgets/listing_card.dart';

class MarketplaceHomeScreen extends ConsumerWidget {
  const MarketplaceHomeScreen({super.key});

  static const List<String> _categories = [
    'Electronics',
    'Fashion',
    'Furniture',
    'Books',
    'Home',
    'Sports',
    'Other',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final listingsAsync = ref.watch(
      filteredListingsProvider(
        ListingFilter(
          searchQuery: '',
          category: 'All',
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.recycling_rounded,
              color: colors.primary,
            ),
            const SizedBox(width: 8),
            const Text(
              'ReUse',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              // Connect to the notifications route
              // when that route is verified.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Notifications are not connected yet.',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(availableListingsProvider);
          await Future<void>.delayed(
            const Duration(milliseconds: 400),
          );
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20, 18, 20, 8,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover something new',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Give pre-loved items a new story.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Search shortcut opens Explore.
                    InkWell(
                      onTap: () => context.go('/explore'),
                      borderRadius:
                          BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'What are you looking for?',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    _SectionHeading(
                      title: 'Browse categories',
                      actionLabel: 'See all',
                      onAction: () => context.go('/explore'),
                    ),
                    const SizedBox(height: 14),

                    SizedBox(
                      height: 94,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final category =
                              _categories[index];

                          return _CategoryShortcut(
                            category: category,
                            onTap: () =>
                                context.go('/explore'),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 26),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius:
                            BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.favorite_outline_rounded,
                            color: colors.onPrimaryContainer,
                            size: 30,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Good finds. Better impact.',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Discover useful items and give '
                            'them another chance to shine.',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () =>
                                context.go('/explore'),
                            child: const Text(
                              'Start exploring',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    _SectionHeading(
                      title: 'Recommended for you',
                      actionLabel: 'Explore',
                      onAction: () => context.go('/explore'),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Listings from the existing Firestore provider.
            listingsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (error, stack) =>
                  SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 42,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Could not load listings.',
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          ref.invalidate(
                            availableListingsProvider,
                          );
                        },
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (listings) {
                if (listings.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 52,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No items available yet.',
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () =>
                                context.go('/sell'),
                            child: const Text(
                              'Be the first to list an item',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Temporary discovery selection.
                // Personal recommendations will require
                // a separate recommendation strategy.
                final recommended =
                    listings.take(4).toList();

                return SliverList(
                  delegate: SliverChildListDelegate([
                    _ListingGrid(
                      listings: recommended,
                    ),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: _SectionHeading(
                        title: 'More to discover',
                        actionLabel: 'See all',
                        onAction: () =>
                            context.go('/explore'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ListingGrid(
                      listings: listings,
                    ),
                    const SizedBox(height: 24),
                  ]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeading({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class _CategoryShortcut extends StatelessWidget {
  final String category;
  final VoidCallback onTap;

  const _CategoryShortcut({
    required this.category,
    required this.onTap,
  });

  IconData get icon {
    switch (category) {
      case 'Electronics':
        return Icons.devices_outlined;
      case 'Fashion':
        return Icons.checkroom_outlined;
      case 'Furniture':
        return Icons.chair_outlined;
      case 'Books':
        return Icons.menu_book_outlined;
      case 'Home':
        return Icons.home_outlined;
      case 'Sports':
        return Icons.sports_basketball_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: colors.onPrimaryContainer,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingGrid extends StatelessWidget {
  final List<dynamic> listings;

  const _ListingGrid({
    required this.listings,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: listings.length,
      gridDelegate:
          const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final listing = listings[index];

        return ListingCard(
          listing: listing,
          onTap: () {
            context.push(
              '/home/listings/${listing.id}',
            );
          },
        );
      },
    );
  }
}
