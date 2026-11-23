import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection('users').doc(uid);

  @override
  Stream<UserProfile?> watchProfile(String uid) {
  debugPrint('PROFILE: Looking for UID $uid');

  return _doc(uid).snapshots().map((snapshot) {
    debugPrint('PROFILE: Document exists = ${snapshot.exists}');
    debugPrint('PROFILE: Document ID = ${snapshot.id}');

    final data = snapshot.data();
      if (data == null) return null;
      return UserProfile(
        uid: uid,
        displayName: data['displayName'] as String? ?? '',
        photoUrl: data['photoUrl'] as String?,
        bio: data['bio'] as String? ?? '',
        generalLocation: data['generalLocation'] as String? ?? '',
        verificationBadge: data['verificationBadge'] as String? ?? 'none',
      );
    });
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String displayName,
    required String bio,
    required String generalLocation,
  }) {
    return _doc(uid).update({
      'displayName': displayName.trim(),
      'bio': bio.trim(),
      'generalLocation': generalLocation.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> setVerificationBadge({required String uid, required String badge}) {
    return _doc(uid).update({
      'verificationBadge': badge,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}