
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/looking_for_request_model.dart';
import '../../data/repositories/looking_for_repository_impl.dart';
import '../../domain/repositories/looking_for_repository.dart';

// Repository dependency.
final lookingForRepositoryProvider =
    Provider<LookingForRepository>((ref) {
  return LookingForRepositoryImpl();
});

// Live feed of all open Looking For requests.
final openLookingForRequestsProvider =
    StreamProvider<List<LookingForRequestModel>>((ref) {
  final repository = ref.watch(lookingForRepositoryProvider);
  return repository.watchRequests();
});

// Live requests belonging to one user.
final userLookingForRequestsProvider =
    StreamProvider.family<List<LookingForRequestModel>, String>(
  (ref, authorId) {
    final repository = ref.watch(lookingForRepositoryProvider);
    return repository.watchUserRequests(authorId);
  },
);

// Retrieve a request by its document ID.
final lookingForRequestDetailsProvider =
    FutureProvider.family<LookingForRequestModel?, String>(
  (ref, requestId) {
    final repository = ref.watch(lookingForRepositoryProvider);
    return repository.getRequestById(requestId);
  },
);

// Filter the open Looking For requests.
final filteredLookingForRequestsProvider =
    Provider.family<
        AsyncValue<List<LookingForRequestModel>>,
        LookingForFilter>(
  (ref, filter) {
    final requests = ref.watch(openLookingForRequestsProvider);

    return requests.whenData((items) {
      return items.where((request) {
        final query = filter.searchQuery.trim().toLowerCase();

        final matchesSearch = query.isEmpty ||
            request.title.toLowerCase().contains(query) ||
            request.description.toLowerCase().contains(query) ||
            request.category.toLowerCase().contains(query);

        final matchesCategory = filter.category == null ||
            filter.category == 'All' ||
            request.category == filter.category;

        final matchesLocation = filter.location == null ||
            filter.location!.trim().isEmpty ||
            request.location.toLowerCase().contains(
                  filter.location!.trim().toLowerCase(),
                );

        final matchesBudget = filter.maxBudget == null ||
            request.minBudget == null ||
            request.minBudget! <= filter.maxBudget!;

        return matchesSearch &&
            matchesCategory &&
            matchesLocation &&
            matchesBudget;
      }).toList();
    });
  },
);

// Immutable filter settings.
class LookingForFilter {
  final String searchQuery;
  final String? category;
  final String? location;
  final double? maxBudget;

  const LookingForFilter({
    this.searchQuery = '',
    this.category,
    this.location,
    this.maxBudget,
  });

  @override
  bool operator ==(Object other) {
    return other is LookingForFilter &&
        other.searchQuery == searchQuery &&
        other.category == category &&
        other.location == location &&
        other.maxBudget == maxBudget;
  }

  @override
  int get hashCode => Object.hash(
        searchQuery,
        category,
        location,
        maxBudget,
      );
}
