import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/repositories/auth_repository.dart';

/// Firebase implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static Future<void>? _googleInitialization;

  Future<void> _initializeGoogle() {
    return _googleInitialization ??=
        GoogleSignIn.instance.initialize(
  serverClientId: '999322875215-k3p3ssedbfkcgcrm1qjlvjm8aoh9ibhk.apps.googleusercontent.com',
);
  }

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
  Future<void> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    await _initializeGoogle();

    final googleSignIn = GoogleSignIn.instance;

    if (!googleSignIn.supportsAuthenticate()) {
      throw UnsupportedError(
        'Google Sign-In is not supported on this platform.',
      );
    }

    final googleUser = await googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;

    if (googleAuth.idToken == null) {
      throw FirebaseAuthException(
        code: 'missing-google-token',
        message: 'Google did not return an authentication token.',
      );
    }

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);
    final user = result.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'Google authentication did not return a user.',
      );
    }

    final profileRef = _firestore.collection('users').doc(user.uid);
    final privateRef = _firestore.collection('userPrivate').doc(user.uid);

    final now = FieldValue.serverTimestamp();

    // Create missing profiles only. Existing user data is preserved.
    final profile = await profileRef.get();

    if (!profile.exists) {
      await profileRef.set({
        'uid': user.uid,
        'displayName': user.displayName ?? googleUser.displayName ?? '',
        'photoUrl': user.photoURL,
        'bio': '',
        'generalLocation': '',
        'verificationBadge': 'none',
        'createdAt': now,
        'updatedAt': now,
      });
    }

    final privateProfile = await privateRef.get();

    if (!privateProfile.exists) {
      await privateRef.set({
        'uid': user.uid,
        'email': user.email ?? googleUser.email,
        'phoneNumber': user.phoneNumber,
        'notificationOptIn': true,
        'createdAt': now,
        'updatedAt': now,
      });
    }
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
  Future<void> signOut() async {
    await _auth.signOut();

    // Clear Google's cached session when available.
    if (_googleInitialization != null) {
      await _initializeGoogle();
      await GoogleSignIn.instance.signOut();
    }
  }
}