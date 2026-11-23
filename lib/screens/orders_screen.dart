
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/orders/data/models/order_model.dart';
import '../features/orders/presentation/providers/order_providers.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'review_screen.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  int tab = 0;
  String? processingOrderId;

  (String, Color, Color) _statusStyle(MarketplaceOrder order) {
    switch (order.status) {
      case MarketplaceOrderStatus.pending:
        return ('Pending · Demo', AppColors.sand, AppColors.ink);

      case MarketplaceOrderStatus.confirmed:
        return ('Confirmed', AppColors.mint, AppColors.green);

      case MarketplaceOrderStatus.inTransit:
        return ('On the way', AppColors.sand, AppColors.ink);

      case MarketplaceOrderStatus.delivered:
        return (
          tab == 0
              ? 'Delivered · Confirm receipt'
              : 'Awaiting buyer',
          AppColors.blush,
          AppColors.danger,
        );

      case MarketplaceOrderStatus.completed:
        return (
          'Completed · Demo',
          AppColors.mint,
          AppColors.green,
        );

      case MarketplaceOrderStatus.cancelled:
        return (
          'Cancelled',
          AppColors.blush,
          AppColors.danger,
        );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatAmount(double amount) {
    return rwf(amount.round());
  }

  Future<void> _updateStatus(
    MarketplaceOrder order,
    MarketplaceOrderStatus status,
  ) async {
    setState(() => processingOrderId = order.id);

    try {
      await ref.read(orderControllerProvider).updateStatus(
            orderId: order.id,
            status: status,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order status updated.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update order: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => processingOrderId = null);
      }
    }
  }

  Future<void> _confirmDelivery(MarketplaceOrder order) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Did you receive the item?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Confirm that ${order.listingTitle} matches '
                  'the listing. This will mark your demo order '
                  'as completed. No actual payment is released.',
                  style: const TextStyle(
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext, true);
                  },
                  child: const Text('Confirm receipt'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext, false);
                  },
                  child: const Text('Not yet'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => processingOrderId = order.id);

    try {
      await ref
          .read(orderControllerProvider)
          .completeDemoOrder(order.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demo order marked as completed.'),
        ),
      );

      _openReview(order);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not complete order: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => processingOrderId = null);
      }
    }
  }

  void _openReview(MarketplaceOrder order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewScreen(
          sellerName: 'Seller',
          onSubmitted: () {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Review submitted.'),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(MarketplaceOrder order) {
    final (label, bg, fg) = _statusStyle(order);

    final isPurchase = tab == 0;
    final isProcessing = processingOrderId == order.id;

    final needsConfirmation = isPurchase &&
        order.status == MarketplaceOrderStatus.delivered;

    final canReview = isPurchase &&
        order.status == MarketplaceOrderStatus.completed;

    final canConfirmSale = !isPurchase &&
        order.status == MarketplaceOrderStatus.pending;

    final canMarkTransit = !isPurchase &&
        order.status == MarketplaceOrderStatus.confirmed;

    final canMarkDelivered = !isPurchase &&
        order.status == MarketplaceOrderStatus.inTransit;

    final shortId = order.id.length > 8
        ? order.id.substring(0, 8)
        : order.id;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.listingTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Pill(
                label,
                bg: bg,
                fg: fg,
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            '${isPurchase ? 'Seller' : 'Buyer'}'
            ' · ${_formatDate(order.createdAt)}'
            ' · #$shortId',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _formatAmount(order.totalAmount),
            style: const TextStyle(
              color: AppColors.green,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            order.deliveryMethod == 'delivery'
                ? 'Delivery'
                : 'Pickup',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Demo transaction · No payment charged',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 11,
            ),
          ),

          if (canConfirmSale) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isProcessing
                  ? null
                  : () => _updateStatus(
                        order,
                        MarketplaceOrderStatus.confirmed,
                      ),
              child: const Text('Confirm order'),
            ),
          ],

          if (canMarkTransit) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isProcessing
                  ? null
                  : () => _updateStatus(
                        order,
                        MarketplaceOrderStatus.inTransit,
                      ),
              child: Text(
                order.deliveryMethod == 'delivery'
                    ? 'Mark as on the way'
                    : 'Mark as ready for pickup',
              ),
            ),
          ],

          if (canMarkDelivered) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isProcessing
                  ? null
                  : () => _updateStatus(
                        order,
                        MarketplaceOrderStatus.delivered,
                      ),
              child: Text(
                order.deliveryMethod == 'delivery'
                    ? 'Mark as delivered'
                    : 'Mark as handed over',
              ),
            ),
          ],

          if (needsConfirmation) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isProcessing
                  ? null
                  : () => _confirmDelivery(order),
              child: const Text('Confirm I received it'),
            ),
          ],

          if (canReview) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _openReview(order),
              child: const Text('Rate this seller'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My orders'),
        ),
        body: const Center(
          child: Text('Please sign in to view your orders.'),
        ),
      );
    }

    final ordersAsync = tab == 0
        ? ref.watch(purchasesProvider)
        : ref.watch(salesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My orders'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              4,
              16,
              8,
            ),
            child: Segmented(
              options: const ['Purchases', 'Sales'],
              selected: tab,
              onChanged: (index) {
                setState(() => tab = index);
              },
            ),
          ),

          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),

              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 40,
                        color: AppColors.muted,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Could not load orders',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          if (tab == 0) {
                            ref.invalidate(purchasesProvider);
                          } else {
                            ref.invalidate(salesProvider);
                          }
                        },
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              ),

              data: (orders) {
                if (orders.isEmpty) {
                  return const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No orders yet',
                    body:
                        'Your orders will show up here once '
                        'you buy or sell something.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    if (tab == 0) {
                      ref.invalidate(purchasesProvider);
                      await ref.read(purchasesProvider.future);
                    } else {
                      ref.invalidate(salesProvider);
                      await ref.read(salesProvider.future);
                    }
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      return _buildOrderCard(orders[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
