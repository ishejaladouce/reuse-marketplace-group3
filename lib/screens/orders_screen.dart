import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'review_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int tab = 0; // 0 Purchases, 1 Sales

  (String, Color, Color) _statusStyle(Order o) {
    switch (o.status) {
      case OrderStatus.paidHeld:
        return (o.isPurchase ? 'Paid, held by Reuse' : 'Paid, ready to hand over', AppColors.sand, AppColors.ink);
      case OrderStatus.inTransit:
        return ('On the way', AppColors.sand, AppColors.ink);
      case OrderStatus.delivered:
        return (o.isPurchase ? 'Delivered, confirm it' : 'Waiting for buyer to confirm', AppColors.blush, AppColors.danger);
      case OrderStatus.completed:
        return ('Completed', AppColors.mint, AppColors.green);
    }
  }

  Future<void> _confirm(Order o) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Did you receive the item?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Check that ${o.item} matches the listing. Confirming releases your payment to ${o.counterparty}.', style: const TextStyle(color: AppColors.muted, height: 1.4)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm and release payment')),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: () => Navigator.pop(context, false), child: const Text('Report a problem')),
        ]),
      ),
    );
    if (ok == true && mounted) {
      setState(() => o.status = OrderStatus.completed);
      Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewScreen(sellerName: o.counterparty, onSubmitted: () => setState(() => o.reviewed = true))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = MockData.orders.where((o) => o.isPurchase == (tab == 0)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Segmented(options: const ['Purchases', 'Sales'], selected: tab, onChanged: (i) => setState(() => tab = i)),
        ),
        Expanded(
          child: list.isEmpty
              ? const EmptyState(icon: Icons.receipt_long_outlined, title: 'No orders yet', body: 'Your orders will show up here once you buy or sell something.')
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final o = list[i];
                    final (label, bg, fg) = _statusStyle(o);
                    final needsConfirm = o.isPurchase && o.status == OrderStatus.delivered;
                    final canReview = o.isPurchase && o.status == OrderStatus.completed && !o.reviewed;
                    return AppCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(o.item, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
                          Pill(label, bg: bg, fg: fg),
                        ]),
                        const SizedBox(height: 6),
                        Text('${o.isPurchase ? 'Seller' : 'Buyer'}: ${o.counterparty}  ·  ${o.date}  ·  ${o.id}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(rwf(o.price), style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w800, fontSize: 16)),
                        if (needsConfirm) ...[
                          const SizedBox(height: 12),
                          ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)), onPressed: () => _confirm(o), child: const Text('Confirm I received it')),
                        ],
                        if (canReview) ...[
                          const SizedBox(height: 12),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewScreen(sellerName: o.counterparty, onSubmitted: () => setState(() => o.reviewed = true)))),
                            child: const Text('Rate this seller'),
                          ),
                        ],
                      ]),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
