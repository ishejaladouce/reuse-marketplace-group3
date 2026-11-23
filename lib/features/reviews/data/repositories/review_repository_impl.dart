import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/review_repository.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reviews => _firestore.collection('reviews');

  @override
  Future<ReviewableOrder?> getOrder(String orderId) async {
    final snapshot = await _firestore.collection('orders').doc(orderId).get();
    final data = snapshot.data();
    if (data == null) return null;
    return ReviewableOrder(
      orderId: orderId,
      buyerId: data['buyerId'] as String? ?? '',
      sellerId: data['sellerId'] as String? ?? '',
      itemTitle: data['itemTitle'] as String? ?? 'Your order',
      status: data['status'] as String? ?? '',
    );
  }

  @override
  Future<bool> hasReview(String orderId) async {
    final snapshot = await _reviews.doc(orderId).get();
    return snapshot.exists;
  }

  @override
  Future<void> submitReview(Review review) {
    // The review ID is the order ID, so each order can only be reviewed once.
    return _reviews.doc(review.orderId).set(review.toMap());
  }

  @override
  Stream<List<Review>> watchReviewsForSeller(String sellerId) {
    return _reviews.where('sellerId', isEqualTo: sellerId).snapshots().map((snapshot) {
      final reviews = snapshot.docs.map((doc) => Review.fromMap(doc.id, doc.data())).toList();
      // Sorted here instead of in the query, so no extra Firestore index is needed.
      reviews.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
      return reviews;
    });
  }
}