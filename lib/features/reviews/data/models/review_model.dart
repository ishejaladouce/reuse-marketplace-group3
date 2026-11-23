import 'package:cloud_firestore/cloud_firestore.dart';

/// Tags a buyer can pick to say what went well. Key = saved value, value = label.
const reviewTags = {
  'responsive': 'Responsive',
  'accurate': 'Item as described',
  'on_time': 'On time',
  'friendly': 'Friendly',
};

/// A buyer's review of a seller, stored in reviews/{orderId} (one review per order).
class Review {
  const Review({
    required this.orderId,
    required this.reviewerId,
    required this.sellerId,
    required this.rating,
    required this.comment,
    this.wentWellTags = const [],
    this.createdAt,
  });

  final String orderId;
  final String reviewerId;
  final String sellerId;
  final int rating;
  final String comment;
  final List<String> wentWellTags;
  final DateTime? createdAt;

  factory Review.fromMap(String orderId, Map<String, dynamic> map) {
    return Review(
      orderId: orderId,
      reviewerId: map['reviewerId'] as String? ?? '',
      sellerId: map['sellerId'] as String? ?? '',
      rating: (map['rating'] as num?)?.toInt() ?? 0,
      comment: map['comment'] as String? ?? '',
      wentWellTags: List<String>.from(map['wentWellTags'] as List? ?? const []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'orderId': orderId,
        'reviewerId': reviewerId,
        'sellerId': sellerId,
        'rating': rating,
        'comment': comment.trim(),
        'wentWellTags': wentWellTags,
        'createdAt': FieldValue.serverTimestamp(),
      };

  /// The comment must say something useful, without being an essay.
  static String? validateComment(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please write a short comment';
    if (text.length < 10) return 'Comment must be at least 10 characters';
    if (text.length > 500) return 'Comment must be 500 characters or fewer';
    return null;
  }
}

/// The parts of an order (owned by the orders feature) that reviews need.
class ReviewableOrder {
  const ReviewableOrder({
    required this.orderId,
    required this.buyerId,
    required this.sellerId,
    required this.itemTitle,
    required this.status,
  });

  final String orderId;
  final String buyerId;
  final String sellerId;
  final String itemTitle;
  final String status;
}

/// Whether the current user may review an order, and why not if they can't.
class ReviewEligibility {
  const ReviewEligibility({this.order, this.reason});

  final ReviewableOrder? order;
  final String? reason;

  bool get canReview => reason == null;
}

/// Returns why the user cannot review this order, or null if they can.
String? reviewBlockReason({
  required ReviewableOrder? order,
  required String userId,
  required bool alreadyReviewed,
}) {
  if (order == null) return 'This order could not be found.';
  if (order.sellerId == userId) return 'You cannot review yourself.';
  if (order.buyerId != userId) return 'Only the buyer can review this order.';
  if (order.status != 'completed') return 'You can leave a review once the order is completed.';
  if (alreadyReviewed) return 'You have already reviewed this order.';
  return null;
}

/// Average star rating, or 0 when there are no reviews.
double averageRating(List<Review> reviews) {
  if (reviews.isEmpty) return 0;
  final total = reviews.fold<int>(0, (runningTotal, review) => runningTotal + review.rating);
  return total / reviews.length;
}