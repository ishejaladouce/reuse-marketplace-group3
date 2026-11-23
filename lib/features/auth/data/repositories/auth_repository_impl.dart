import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/auth_repository.dart';

/// Firebase implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(fullName.trim());

    final now = FieldValue.serverTimestamp();
    // Public profile: safe for other users to read.
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'displayName': fullName.trim(),
      'photoUrl': null,
      'bio': '',
      'generalLocation': '',
      'verificationBadge': 'none',
      'createdAt': now,
      'updatedAt': now,
    });
    // Private account data: only the owner can read it.
    await _firestore.collection('userPrivate').doc(user.uid).set({
      'uid': user.uid,
      'email': email.trim(),
      'phoneNumber': phoneNumber?.trim(),
      'notificationOptIn': true,
      'createdAt': now,
      'updatedAt': now,
    });

    await user.sendEmailVerification();
  }

  @override
  Future<void> signIn({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  @override
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  @override
  Future<void> signOut() => _auth.signOut();
}