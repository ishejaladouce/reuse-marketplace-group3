
import 'package:cloud_firestore/cloud_firestore.dart';

class LookingForRequestModel {
  final String id;
  final String authorId;
  final String title;
  final String description;
  final String category;
  final String preferredCondition;
  final double? minBudget;
  final double? maxBudget;
  final String currency;
  final String location;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LookingForRequestModel({
    required this.id,
    required this.authorId,
    required this.title,
    required this.description,
    required this.category,
    this.preferredCondition = 'Any',
    this.minBudget,
    this.maxBudget,
    this.currency = 'RWF',
    required this.location,
    this.status = 'open',
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert a Firestore document into a Dart object.
  factory LookingForRequestModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();

    if (data == null) {
      throw StateError(
        'Looking For request ${snapshot.id} does not exist.',
      );
    }

    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return LookingForRequestModel(
      id: snapshot.id,
      authorId: data['authorId'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      category: data['category'] as String,
      preferredCondition:
          data['preferredCondition'] as String? ?? 'Any',
      minBudget: (data['minBudget'] as num?)?.toDouble(),
      maxBudget: (data['maxBudget'] as num?)?.toDouble(),
      currency: data['currency'] as String? ?? 'RWF',
      location: data['location'] as String,
      status: data['status'] as String? ?? 'open',
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
    );
  }

  // Convert this model into data that Firestore can store.
  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'title': title,
      'description': description,
      'category': category,
      'preferredCondition': preferredCondition,
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'currency': currency,
      'location': location,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create an updated copy without changing the original object.
  LookingForRequestModel copyWith({
    String? id,
    String? authorId,
    String? title,
    String? description,
    String? category,
    String? preferredCondition,
    double? minBudget,
    double? maxBudget,
    bool clearMinBudget = false,
    bool clearMaxBudget = false,
    String? currency,
    String? location,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LookingForRequestModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      preferredCondition:
          preferredCondition ?? this.preferredCondition,
      minBudget:
          clearMinBudget ? null : minBudget ?? this.minBudget,
      maxBudget:
          clearMaxBudget ? null : maxBudget ?? this.maxBudget,
      currency: currency ?? this.currency,
      location: location ?? this.location,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
