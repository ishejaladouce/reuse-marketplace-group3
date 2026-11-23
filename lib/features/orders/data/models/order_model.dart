
import 'package:cloud_firestore/cloud_firestore.dart';

enum MarketplaceOrderStatus {
  pending,
  confirmed,
  inTransit,
  delivered,
  completed,
  cancelled,
}

class MarketplaceOrder {
  final String id;
  final String listingId;
  final String listingTitle;
  final String buyerId;
  final String sellerId;
  final double itemPrice;
  final double platformFee;
  final double deliveryFee;
  final double totalAmount;
  final String currency;
  final String deliveryMethod;
  final String deliveryAddress;
  final String paymentMethod;
  final String paymentStatus;
  final MarketplaceOrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MarketplaceOrder({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.buyerId,
    required this.sellerId,
    required this.itemPrice,
    required this.platformFee,
    required this.deliveryFee,
    required this.totalAmount,
    this.currency = 'RWF',
    required this.deliveryMethod,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.paymentStatus = 'demo_not_charged',
    this.status = MarketplaceOrderStatus.pending,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'listingId': listingId,
      'listingTitle': listingTitle,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'itemPrice': itemPrice,
      'platformFee': platformFee,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'currency': currency,
      'deliveryMethod': deliveryMethod,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory MarketplaceOrder.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final statusString = data['status'] as String? ?? 'pending';

    final status = MarketplaceOrderStatus.values.firstWhere(
      (value) => value.name == statusString,
      orElse: () => MarketplaceOrderStatus.pending,
    );

    return MarketplaceOrder(
      id: doc.id,
      listingId: data['listingId'] as String? ?? '',
      listingTitle: data['listingTitle'] as String? ?? '',
      buyerId: data['buyerId'] as String? ?? '',
      sellerId: data['sellerId'] as String? ?? '',
      itemPrice: (data['itemPrice'] as num? ?? 0).toDouble(),
      platformFee: (data['platformFee'] as num? ?? 0).toDouble(),
      deliveryFee: (data['deliveryFee'] as num? ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] as num? ?? 0).toDouble(),
      currency: data['currency'] as String? ?? 'RWF',
      deliveryMethod: data['deliveryMethod'] as String? ?? 'pickup',
      deliveryAddress: data['deliveryAddress'] as String? ?? '',
      paymentMethod: data['paymentMethod'] as String? ?? '',
      paymentStatus:
          data['paymentStatus'] as String? ?? 'demo_not_charged',
      status: status,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ??
              DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ??
              DateTime.now(),
    );
  }

  MarketplaceOrder copyWith({
    MarketplaceOrderStatus? status,
    String? paymentStatus,
    DateTime? updatedAt,
  }) {
    return MarketplaceOrder(
      id: id,
      listingId: listingId,
      listingTitle: listingTitle,
      buyerId: buyerId,
      sellerId: sellerId,
      itemPrice: itemPrice,
      platformFee: platformFee,
      deliveryFee: deliveryFee,
      totalAmount: totalAmount,
      currency: currency,
      deliveryMethod: deliveryMethod,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
