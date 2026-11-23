
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

/// Provides the Firestore order repository.
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

/// Watches Firebase authentication changes.
final orderAuthStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Streams purchases belonging to the signed-in user.
final purchasesProvider = StreamProvider<List<MarketplaceOrder>>((ref) {
  final authState = ref.watch(orderAuthStateProvider);

  final user = authState.asData?.value;

  if (user == null) {
    return Stream.value(<MarketplaceOrder>[]);
  }

  final repository = ref.watch(orderRepositoryProvider);

  return repository.watchPurchases(user.uid);
});

/// Streams sales belonging to the signed-in user.
final salesProvider = StreamProvider<List<MarketplaceOrder>>((ref) {
  final authState = ref.watch(orderAuthStateProvider);

  final user = authState.asData?.value;

  if (user == null) {
    return Stream.value(<MarketplaceOrder>[]);
  }

  final repository = ref.watch(orderRepositoryProvider);

  return repository.watchSales(user.uid);
});

/// Provides actions for creating and updating orders.
final orderControllerProvider = Provider<OrderController>((ref) {
  final repository = ref.watch(orderRepositoryProvider);

  return OrderController(repository);
});

class OrderController {
  final OrderRepository _repository;

  OrderController(this._repository);

  /// Creates a new demo order in Firestore.
  Future<String> createOrder(MarketplaceOrder order) async {
    return await _repository.createOrder(order);
  }

  /// Retrieves an order by its document ID.
  Future<MarketplaceOrder?> getOrder(String orderId) async {
    return await _repository.getOrder(orderId);
  }

  /// Updates an order's status.
  Future<void> updateStatus({
    required String orderId,
    required MarketplaceOrderStatus status,
  }) async {
    await _repository.updateOrderStatus(
      orderId: orderId,
      status: status,
    );
  }

  /// Completes a demo order without transferring money.
  Future<void> completeDemoOrder(String orderId) async {
    await _repository.completeDemoOrder(orderId);
  }
}
