
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  // CREATE: Save a new demo order in Firestore.
  Future<String> createOrder(MarketplaceOrder order) async {
    if (order.buyerId.isEmpty ||
        order.sellerId.isEmpty ||
        order.listingId.isEmpty) {
      throw ArgumentError('Missing required order information.');
    }

    if (order.buyerId == order.sellerId) {
      throw StateError('You cannot purchase your own listing.');
    }

    if (order.itemPrice <= 0 || order.totalAmount <= 0) {
      throw ArgumentError('Order amounts must be positive.');
    }

    if (order.paymentStatus != 'demo_not_charged') {
      throw StateError('Only demo orders are supported.');
    }

    final doc = _orders.doc();

    await doc.set(order.toFirestore());

    return doc.id;
  }

  // READ: Retrieve one order.
  Future<MarketplaceOrder?> getOrder(String orderId) async {
    final snapshot = await _orders.doc(orderId).get();

    if (!snapshot.exists) return null;

    return MarketplaceOrder.fromFirestore(snapshot);
  }

  // READ: Watch orders belonging to a buyer.
  Stream<List<MarketplaceOrder>> watchPurchases(String buyerId) {
    return _orders
        .where('buyerId', isEqualTo: buyerId)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs
          .map(MarketplaceOrder.fromFirestore)
          .toList();

      orders.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );

      return orders;
    });
  }

  // READ: Watch orders belonging to a seller.
  Stream<List<MarketplaceOrder>> watchSales(String sellerId) {
    return _orders
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs
          .map(MarketplaceOrder.fromFirestore)
          .toList();

      orders.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );

      return orders;
    });
  }

  // UPDATE: Change an order's status.
  //
  // This updates order tracking only.
  // It does NOT charge or release real money.
  Future<void> updateOrderStatus({
    required String orderId,
    required MarketplaceOrderStatus status,
  }) async {
    await _orders.doc(orderId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // UPDATE: Mark a demo order as completed.
  //
  // No actual payment is released.
  Future<void> completeDemoOrder(String orderId) async {
    await _orders.doc(orderId).update({
      'status': MarketplaceOrderStatus.completed.name,
      'paymentStatus': 'demo_not_charged',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
