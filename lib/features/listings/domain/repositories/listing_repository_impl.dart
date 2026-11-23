
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/listing_repository.dart';
import '../../data/models/listing_model.dart';
class ListingRepositoryImpl implements ListingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ListingRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _listings =>
      _firestore.collection('listings');

  String get _currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('You must be signed in.');
    }

    return user.uid;
  }

  @override
  Future<String> createListing(ListingModel listing) async {
    final uid = _currentUserId;

    if (listing.sellerId != uid) {
      throw StateError('You cannot create another user\'s listing.');
    }

    if (listing.title.trim().isEmpty ||
        listing.description.trim().isEmpty ||
        listing.price <= 0) {
      throw ArgumentError('Please provide valid listing details.');
    }

    final now = DateTime.now();
    final document = _listings.doc();

    final newListing = listing.copyWith(
      id: document.id,
      createdAt: now,
      updatedAt: now,
      status: 'available',
    );

    await document.set(newListing.toFirestore());

    return document.id;
  }

  @override
  Future<ListingModel?> getListingById(String listingId) async {
    final snapshot = await _listings.doc(listingId).get();

    if (!snapshot.exists) return null;

    return ListingModel.fromFirestore(snapshot);
  }

  @override
  Stream<List<ListingModel>> watchListings() {
    return _listings
        .where('status', isEqualTo: 'available')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ListingModel.fromFirestore)
              .toList(),
        );
  }

  @override
  Stream<List<ListingModel>> watchUserListings(String sellerId) {
    return _listings
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ListingModel.fromFirestore)
              .toList(),
        );
  }

  @override
  Future<void> updateListing(ListingModel listing) async {
    final uid = _currentUserId;

    final document = await _listings.doc(listing.id).get();

    if (!document.exists) {
      throw StateError('Listing not found.');
    }

    final existing = ListingModel.fromFirestore(document);

    if (existing.sellerId != uid) {
      throw StateError('You can only edit your own listings.');
    }

    if (listing.sellerId != existing.sellerId) {
      throw StateError('The listing owner cannot be changed.');
    }

    if (listing.title.trim().isEmpty ||
        listing.description.trim().isEmpty ||
        listing.price <= 0) {
      throw ArgumentError('Please provide valid listing details.');
    }

    final updated = listing.copyWith(
      sellerId: existing.sellerId,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );

    await _listings.doc(listing.id).update(updated.toFirestore());
  }

  @override
  Future<void> deleteListing(String listingId) async {
    final uid = _currentUserId;
    final document = await _listings.doc(listingId).get();

    if (!document.exists) {
      throw StateError('Listing not found.');
    }

    if (document.data()?['sellerId'] != uid) {
      throw StateError('You can only delete your own listings.');
    }

    await _listings.doc(listingId).delete();
  }
}
