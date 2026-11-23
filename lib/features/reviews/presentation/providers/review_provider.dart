import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/firebase_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../domain/repositories/review_repository.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => ReviewRepositoryImpl(ref.watch(firestoreProvider)),
);

/// Live list of reviews about a seller.
final sellerReviewsProvider = StreamProvider.family<List<Review>, String>(
  (ref, sellerId) => ref.watch(reviewRepositoryProvider).watchReviewsForSeller(sellerId),
);

/// Loads an order and checks whether the logged-in user may review it.
final reviewEligibilityProvider =
    FutureProvider.family<ReviewEligibility, String>((ref, orderId) async {
  final user = ref.watch(authStateProvider).asData?.value;
  final repository = ref.watch(reviewRepositoryProvider);

  final order = await repository.getOrder(orderId);
  final alreadyReviewed = order != null && await repository.hasReview(orderId);

  return ReviewEligibility(
    order: order,
    reason: reviewBlockReason(
      order: order,
      userId: user?.uid ?? '',
      alreadyReviewed: alreadyReviewed,
    ),
  );
});

/// Sends a new review and tracks loading and errors.
class SubmitReviewController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> submit({
    required ReviewableOrder order,
    required int rating,
    required String comment,
    required List<String> tags,
  }) async {
    final user = ref.read(authStateProvider).asData?.value;
    if (user == null) return false;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(reviewRepositoryProvider).submitReview(Review(
            orderId: order.orderId,
            reviewerId: user.uid,
            sellerId: order.sellerId,
            rating: rating,
            comment: comment,
            wentWellTags: tags,
          )),
    );
    return !state.hasError;
  }
}

final submitReviewControllerProvider =
    AsyncNotifierProvider<SubmitReviewController, void>(SubmitReviewController.new);