
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../listings/data/models/listing_model.dart';
import '../../../listings/presentation/providers/listing_providers.dart';
import '../../../listings/presentation/screens/listing_details_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Electronics',
    'Fashion',
    'Furniture',
    'Books',
    'Home',
    'Sports',
    'Other',
  ];

  final Map<String, String> _categoryImages = {
    'Electronics': 'assets/images/categories/electronics.jpg',
    'Fashion': 'assets/images/categories/fashion.jpg',
    'Furniture': 'assets/images/categories/furniture.jpg',
    'Books': 'assets/images/categories/books.jpg',
    'Home': 'assets/images/categories/home.jpg',
    'Sports': 'assets/images/categories/sports.jpg',
    'Other': 'assets/images/categories/other.jpg',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final listings = ref.watch(
      filteredListingsProvider(
        ListingFilter(
          searchQuery: _searchQuery,
          category: _selectedCategory,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explore',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Find your next great discovery',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Explore pre-loved items from people around you.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Search for items...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'Shop by category',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 132,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categoryImages.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final category =
                                  _categoryImages.keys.elementAt(index);

                              return _CategoryImageCard(
                                category: category,
                                imagePath: _categoryImages[category]!,
                                selected:
                                    _selectedCategory == category,
                                onTap: () {
                                  setState(() {
                                    _selectedCategory =
                                        _selectedCategory == category
                                            ? 'All'
                                            : category;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final category = _categories[index];

                              return ChoiceChip(
                                label: Text(category),
                                selected:
                                    _selectedCategory == category,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          _selectedCategory == 'All'
                              ? 'Discover items'
                              : '$_selectedCategory items',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                ...listings.when(
                  loading: () => [
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ],
                  error: (error, stack) => [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Could not load items: $error',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                  data: (items) {
                    if (items.isEmpty) {
                      return [
                        SliverToBoxAdapter(
                          child: _EmptyResults(
                            isSearching:
                                _searchQuery.trim().isNotEmpty ||
                                _selectedCategory != 'All',
                            onLookingFor: () =>
                                _openLookingFor(context),
                          ),
                        ),
                      ];
                    }

                    return [
                      SliverPadding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverLayoutBuilder(
                          builder: (context, constraints) {
                            final columns =
                                constraints.crossAxisExtent >= 700
                                    ? 3
                                    : 2;

                            return SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 258,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final listing = items[index];

                                  return _ExploreListingCard(
                                    listing: listing,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ListingDetailsScreen(
                                            listingId: listing.id,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                childCount: items.length,
                              ),
                            );
                          },
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: OutlinedButton.icon(
                onPressed: () => _openLookingFor(context),
                icon: const Icon(Icons.campaign_outlined),
                label: const Text(
                  "Can't find it? Post a Looking For request",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openLookingFor(BuildContext context) {
    context.push('/explore/looking-for');
  }
}

class _CategoryImageCard extends StatelessWidget {
  final String category;
  final String imagePath;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryImageCard({
    required this.category,
    required this.imagePath,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 112,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 104,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? colorScheme.primary
                      : Colors.transparent,
                  width: selected ? 3 : 0,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.image_outlined,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? colorScheme.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const _ExploreListingCard({
    required this.listing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 158,
              width: double.infinity,
              child: listing.imageUrls.isNotEmpty
                  ? Image.network(
                      listing.imageUrls.first,
                      fit: BoxFit.cover,
                      loadingBuilder: (
                        context,
                        child,
                        loadingProgress,
                      ) {
                        if (loadingProgress == null) return child;

                        return const _ListingImagePlaceholder(
                          loading: true,
                        );
                      },
                      errorBuilder: (_, __, ___) =>
                          const _ListingImagePlaceholder(),
                    )
                  : const _ListingImagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${listing.currency} ${listing.price.toStringAsFixed(0)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          listing.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingImagePlaceholder extends StatelessWidget {
  final bool loading;

  const _ListingImagePlaceholder({
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.primary.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: loading
          ? const CircularProgressIndicator(strokeWidth: 2)
          : Icon(
              Icons.image_outlined,
              size: 48,
              color: colorScheme.primary.withValues(alpha: 0.55),
            ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onLookingFor;

  const _EmptyResults({
    required this.isSearching,
    required this.onLookingFor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.inventory_2_outlined,
              size: 48,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching
                ? 'No matching items found'
                : 'Great finds are coming soon',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try another search or category, or tell the community what you need.'
                : 'Be the first to share something worth giving a second home.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onLookingFor,
            icon: const Icon(Icons.add),
            label: const Text('Post a request'),
          ),
        ],
      ),
    );
  }
}
