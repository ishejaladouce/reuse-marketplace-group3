
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/listing_model.dart';
import '../../data/repositories/listing_repository_impl.dart';
import '../../domain/repositories/listing_repository.dart';

// Repository dependency.
final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ListingRepositoryImpl();
});

// Live feed of available marketplace listings.
final availableListingsProvider =
    StreamProvider<List<ListingModel>>((ref) {
  final repository = ref.watch(listingRepositoryProvider);
  return repository.watchListings();
});

// Live listings belonging to a particular seller.
final userListingsProvider =
    StreamProvider.family<List<ListingModel>, String>(
  (ref, sellerId) {
    final repository = ref.watch(listingRepositoryProvider);
    return repository.watchUserListings(sellerId);
  },
);

// Retrieve one listing by its Firestore document ID.
final listingDetailsProvider =
    FutureProvider.family<ListingModel?, String>(
  (ref, listingId) {
    final repository = ref.watch(listingRepositoryProvider);
    return repository.getListingById(listingId);
  },
);

// Search and filter the available marketplace listings.
// Filtering happens locally on the streamed results.
final filteredListingsProvider =
    Provider.family<AsyncValue<List<ListingModel>>, ListingFilter>(
  (ref, filter) {
    final listings = ref.watch(availableListingsProvider);

    return listings.whenData((items) {
      return items.where((listing) {
        final query = filter.searchQuery.trim().toLowerCase();

        final matchesSearch = query.isEmpty ||
            listing.title.toLowerCase().contains(query) ||
            listing.description.toLowerCase().contains(query) ||
            listing.category.toLowerCase().contains(query);

        final matchesCategory = filter.category == null ||
            filter.category == 'All' ||
            listing.category == filter.category;

        final matchesCondition = filter.condition == null ||
            filter.condition == 'All' ||
            listing.condition == filter.condition;

        final matchesMinPrice = filter.minPrice == null ||
            listing.price >= filter.minPrice!;

        final matchesMaxPrice = filter.maxPrice == null ||
            listing.price <= filter.maxPrice!;

        return matchesSearch &&
            matchesCategory &&
            matchesCondition &&
            matchesMinPrice &&
            matchesMaxPrice;
      }).toList();
    });
  },
);

// Immutable filter settings.
class ListingFilter {
  final String searchQuery;
  final String? category;
  final String? condition;
  final double? minPrice;
  final double? maxPrice;

  const ListingFilter({
    this.searchQuery = '',
    this.category,
    this.condition,
    this.minPrice,
    this.maxPrice,
  });

  @override
  bool operator ==(Object other) {
    return other is ListingFilter &&
        other.searchQuery == searchQuery &&
        other.category == category &&
        other.condition == condition &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice;
  }

  @override
  int get hashCode => Object.hash(
        searchQuery,
        category,
        condition,
        minPrice,
        maxPrice,
      );
}
