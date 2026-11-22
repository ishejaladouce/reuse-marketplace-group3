
import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  final String id;
  final String sellerId;
  final String title;
  final String description;
  final double price;
  final String currency;
  final String category;
  final String condition;
  final List<String> imageUrls;
  final String location;
  final String status;
  final bool pickupAvailable;
  final bool deliveryAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ListingModel({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.price,
    this.currency = 'RWF',
    required this.category,
    required this.condition,
    this.imageUrls = const [],
    required this.location,
    this.status = 'available',
    this.pickupAvailable = true,
    this.deliveryAvailable = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ListingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;

    return ListingModel(
      id: snapshot.id,
      sellerId: data['sellerId'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      price: (data['price'] as num).toDouble(),
      currency: data['currency'] as String? ?? 'RWF',
      category: data['category'] as String,
      condition: data['condition'] as String,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      location: data['location'] as String,
      status: data['status'] as String? ?? 'available',
      pickupAvailable: data['pickupAvailable'] as bool? ?? true,
      deliveryAvailable: data['deliveryAvailable'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sellerId': sellerId,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'category': category,
      'condition': condition,
      'imageUrls': imageUrls,
      'location': location,
      'status': status,
      'pickupAvailable': pickupAvailable,
      'deliveryAvailable': deliveryAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ListingModel copyWith({
    String? id,
    String? sellerId,
    String? title,
    String? description,
    double? price,
    String? currency,
    String? category,
    String? condition,
    List<String>? imageUrls,
    String? location,
    String? status,
    bool? pickupAvailable,
    bool? deliveryAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ListingModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      imageUrls: imageUrls ?? this.imageUrls,
      location: location ?? this.location,
      status: status ?? this.status,
      pickupAvailable: pickupAvailable ?? this.pickupAvailable,
      deliveryAvailable: deliveryAvailable ?? this.deliveryAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
