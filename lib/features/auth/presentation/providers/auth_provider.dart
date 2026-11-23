import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/firebase_providers.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

/// Gives the app one AuthRepository, built from the shared Firebase instances.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(firebaseAuthProvider), ref.watch(firestoreProvider));
});

/// Live stream of the signed-in user (null when signed out).
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Runs auth actions and exposes their loading / error state to the UI.
class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) {
    return _run(() => _repository.signUp(
          fullName: fullName,
          email: email,
          password: password,
          phoneNumber: phoneNumber,
        ));
  }

  Future<bool> signIn({required String email, required String password}) {
    return _run(() => _repository.signIn(email: email, password: password));
  }

  Future<bool> sendPasswordReset(String email) => _run(() => _repository.sendPasswordReset(email));
  Future<bool> resendVerificationEmail() => _run(_repository.sendEmailVerification);
  Future<bool> reloadUser() => _run(_repository.reloadUser);
  Future<bool> signOut() => _run(_repository.signOut);

  /// Sets loading, runs the action, then stores success or the error.
  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
    return !state.hasError;
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(AuthController.new);

/// Turns Firebase error codes into messages for the user.
String authErrorMessage(Object? error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
    }
  }
  return 'Something went wrong. Please try again.';
}