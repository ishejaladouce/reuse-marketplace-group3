import '../../data/models/review_model.dart';

abstract class ReviewRepository {
  /// Reads the order a review would be about.
  Future<ReviewableOrder?> getOrder(String orderId);

  /// True if this order already has a review.
  Future<bool> hasReview(String orderId);

  /// Saves a new review. Reviews cannot be edited afterwards.
  Future<void> submitReview(Review review);

  /// All reviews about one seller, newest first.
  Stream<List<Review>> watchReviewsForSeller(String sellerId);
}