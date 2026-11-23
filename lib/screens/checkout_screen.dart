
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/orders/data/models/order_model.dart';
import '../features/orders/presentation/providers/order_providers.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'orders_screen.dart';

/// Three-step prototype checkout:
/// Receive -> Payment details -> Confirm demo order.
///
/// No real money is charged, held, or released.
class CheckoutScreen extends ConsumerStatefulWidget {
  final String listingId;
  final String sellerId;
  final String itemName;
  final String sellerName;
  final int price;

  const CheckoutScreen({
    super.key,
    required this.listingId,
    required this.sellerId,
    required this.itemName,
    required this.price,
    this.sellerName = 'Seller',
  });

  @override
  ConsumerState<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  // Prototype fees only. Confirm with the team before real payments.
  static const double platformFeeRate = 0.05;
  static const int deliveryFee = 3000;

  int step = 0;
  bool delivery = false;
  String provider = 'MTN MoMo';

  final phone = TextEditingController();
  final address = TextEditingController();

  bool paying = false;

  int get fee => (widget.price * platformFeeRate).round();

  int get total =>
      widget.price + fee + (delivery ? deliveryFee : 0);

  bool get canContinue {
    if (step == 0) {
      return !delivery || address.text.trim().isNotEmpty;
    }

    if (step == 1) {
      final digits = phone.text.replaceAll(RegExp(r'\D'), '');
      return digits.length >= 9 && digits.length <= 12;
    }

    return true;
  }

  @override
  void dispose() {
    phone.dispose();
    address.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (paying || !canContinue) return;

    if (step < 2) {
      setState(() => step++);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in before placing an order.'),
        ),
      );
      return;
    }

    if (user.uid == widget.sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot purchase your own listing.'),
        ),
      );
      return;
    }

    setState(() => paying = true);

    try {
      final now = DateTime.now();

      final order = MarketplaceOrder(
        id: '',
        listingId: widget.listingId,
        listingTitle: widget.itemName,
        buyerId: user.uid,
        sellerId: widget.sellerId,
        itemPrice: widget.price.toDouble(),
        platformFee: fee.toDouble(),
        deliveryFee: delivery ? deliveryFee.toDouble() : 0,
        totalAmount: total.toDouble(),
        currency: 'RWF',
        deliveryMethod: delivery ? 'delivery' : 'pickup',
        deliveryAddress: delivery ? address.text.trim() : '',
        paymentMethod: provider,
        paymentStatus: 'demo_not_charged',
        status: MarketplaceOrderStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(orderControllerProvider).createOrder(order);

      if (!mounted) return;

      setState(() => paying = false);

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Demo order created'),
          content: const Text(
            'Your order has been saved successfully. '
            'This is a demonstration checkout: no Mobile Money '
            'payment was charged and no funds are being held.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const OrdersScreen(),
                  ),
                  (route) => route.isFirst,
                );
              },
              child: const Text(
                'View my orders',
                style: TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => paying = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not create order: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const titles = [
      'Receive your item',
      'Mobile Money details',
      'Review demo order',
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: paying
              ? null
              : () {
                  if (step == 0) {
                    Navigator.pop(context);
                  } else {
                    setState(() => step--);
                  }
                },
        ),
        title: const Text('Checkout'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          _Stepper(step: step),
          const SizedBox(height: 16),

          AppCard(
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chair_alt_outlined,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.itemName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        rwf(widget.price),
                        style: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Seller: ${widget.sellerName}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            titles[step],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          if (step == 0) ...[
            _Choice(
              selected: !delivery,
              title: 'Pickup',
              subtitle: 'Arrange a meeting point with the seller',
              trailing: 'Free',
              onTap: () => setState(() => delivery = false),
            ),
            const SizedBox(height: 10),
            _Choice(
              selected: delivery,
              title: 'Delivery',
              subtitle: 'Delivered to your address',
              trailing: rwf(deliveryFee),
              onTap: () => setState(() => delivery = true),
            ),
            if (delivery) ...[
              const SizedBox(height: 12),
              TextField(
                controller: address,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText:
                      'Delivery address (e.g. KG 11 Ave, Kimironko)',
                ),
              ),
            ],
          ],

          if (step == 1) ...[
            Row(
              children: [
                for (final p in ['MTN MoMo', 'Airtel Money'])
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: p == 'MTN MoMo' ? 8 : 0,
                      ),
                      child: _Choice(
                        selected: provider == p,
                        title: p,
                        onTap: () => setState(() => provider = p),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: '+250 7XX XXX XXX',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            const TrustBanner(
              'Demo mode: no Mobile Money prompt will be sent '
              'and no money will be charged.',
            ),
          ],

          if (step == 2) ...[
            AppCard(
              child: Column(
                children: [
                  _Row(
                    'Receive by',
                    delivery ? 'Delivery' : 'Pickup',
                  ),
                  if (delivery)
                    _Row('Address', address.text.trim()),
                  _Row(
                    'Payment method (demo)',
                    provider,
                  ),
                  const _Row(
                    'Payment status',
                    'Not charged',
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          AppCard(
            child: Column(
              children: [
                _Row('Item price', rwf(widget.price)),
                _Row('Platform fee (demo)', rwf(fee)),
                _Row(
                  'Delivery',
                  delivery ? rwf(deliveryFee) : 'Free',
                ),
                const Divider(height: 22),
                _Row(
                  'Total',
                  rwf(total),
                  bold: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          const TrustBanner(
            'Prototype checkout only. Payment protection '
            'and escrow are not active.',
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: canContinue && !paying ? _next : null,
            child: paying
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    step < 2
                        ? 'Continue'
                        : 'Place demo order · ${rwf(total)}',
                  ),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int step;

  const _Stepper({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          CircleAvatar(
            radius: 13,
            backgroundColor:
                i <= step ? AppColors.green : AppColors.border,
            child: i < step
                ? const Icon(
                    Icons.check,
                    size: 15,
                    color: Colors.white,
                  )
                : Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color:
                          i <= step ? Colors.white : AppColors.muted,
                    ),
                  ),
          ),
          if (i < 2)
            Expanded(
              child: Container(
                height: 2,
                color: i < step
                    ? AppColors.green
                    : AppColors.border,
              ),
            ),
        ],
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  final bool selected;
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback onTap;

  const _Choice({
    required this.selected,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.mint : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color:
                  selected ? AppColors.green : AppColors.muted,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                  fontSize: 13,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String l;
  final String r;
  final bool bold;

  const _Row(this.l, this.r, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l,
            style: TextStyle(
              color: bold ? AppColors.ink : AppColors.muted,
              fontWeight:
                  bold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              r,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight:
                    bold ? FontWeight.w800 : FontWeight.w700,
                fontSize: bold ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
