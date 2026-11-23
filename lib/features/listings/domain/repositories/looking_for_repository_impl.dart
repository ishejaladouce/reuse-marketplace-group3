
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/looking_for_repository.dart';
import '../models/looking_for_request_model.dart';

class LookingForRepositoryImpl implements LookingForRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  LookingForRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('lookingForRequests');

  String get _currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('You must be signed in.');
    }

    return user.uid;
  }

  @override
  Future<String> createRequest(
    LookingForRequestModel request,
  ) async {
    final uid = _currentUserId;

    if (request.authorId != uid) {
      throw StateError('You cannot post as another user.');
    }

    _validateRequest(request);

    final now = DateTime.now();
    final document = _requests.doc();

    final newRequest = request.copyWith(
      id: document.id,
      status: 'open',
      createdAt: now,
      updatedAt: now,
    );

    await document.set(newRequest.toFirestore());

    return document.id;
  }

  @override
  Future<LookingForRequestModel?> getRequestById(
    String requestId,
  ) async {
    final snapshot = await _requests.doc(requestId).get();

    if (!snapshot.exists) return null;

    return LookingForRequestModel.fromFirestore(snapshot);
  }

  @override
  Stream<List<LookingForRequestModel>> watchRequests() {
    return _requests
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(LookingForRequestModel.fromFirestore)
              .toList(),
        );
  }

  @override
  Stream<List<LookingForRequestModel>> watchUserRequests(
    String authorId,
  ) {
    return _requests
        .where('authorId', isEqualTo: authorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(LookingForRequestModel.fromFirestore)
              .toList(),
        );
  }

  @override
  Future<void> updateRequest(
    LookingForRequestModel request,
  ) async {
    final uid = _currentUserId;

    final document = await _requests.doc(request.id).get();

    if (!document.exists) {
      throw StateError('Request not found.');
    }

    final existing = LookingForRequestModel.fromFirestore(document);

    if (existing.authorId != uid) {
      throw StateError('You can only edit your own requests.');
    }

    if (request.authorId != existing.authorId) {
      throw StateError('The request author cannot be changed.');
    }

    _validateRequest(request);

    final updated = request.copyWith(
      authorId: existing.authorId,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );

    await _requests.doc(request.id).update(updated.toFirestore());
  }

  @override
  Future<void> deleteRequest(String requestId) async {
    final uid = _currentUserId;
    final document = await _requests.doc(requestId).get();

    if (!document.exists) {
      throw StateError('Request not found.');
    }

    if (document.data()?['authorId'] != uid) {
      throw StateError('You can only delete your own requests.');
    }

    await _requests.doc(requestId).delete();
  }

  void _validateRequest(LookingForRequestModel request) {
    if (request.title.trim().isEmpty ||
        request.description.trim().isEmpty ||
        request.category.trim().isEmpty) {
      throw ArgumentError('Please fill in all required fields.');
    }

    if (request.minBudget != null && request.minBudget! < 0) {
      throw ArgumentError('Minimum budget cannot be negative.');
    }

    if (request.maxBudget != null && request.maxBudget! < 0) {
      throw ArgumentError('Maximum budget cannot be negative.');
    }

    if (request.minBudget != null &&
        request.maxBudget != null &&
        request.minBudget! > request.maxBudget!) {
      throw ArgumentError(
        'Minimum budget cannot exceed maximum budget.',
      );
    }
  }
}
