import 'package:firebase_auth/firebase_auth.dart';

/// What the app can do with accounts. Screens depend on this contract,
/// not on Firebase directly.
abstract class AuthRepository {
  Stream<User?> authStateChanges();
  User? get currentUser;

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  });

  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> sendEmailVerification();
  Future<void> reloadUser();
  Future<void> signOut();
}