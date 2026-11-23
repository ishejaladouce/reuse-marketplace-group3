import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/providers/firebase_providers.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

/// Gives the app one AuthRepository, built from the shared Firebase instances.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

/// Live stream of the signed-in user.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Runs auth actions and exposes their loading / error state.
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

  Future<bool> signIn({
    required String email,
    required String password,
  }) {
    return _run(
      () => _repository.signIn(email: email, password: password),
    );
  }

  Future<bool> signInWithGoogle() {
    return _run(_repository.signInWithGoogle);
  }

  Future<bool> sendPasswordReset(String email) =>
      _run(() => _repository.sendPasswordReset(email));

  Future<bool> resendVerificationEmail() =>
      _run(_repository.sendEmailVerification);

  Future<bool> reloadUser() => _run(_repository.reloadUser);

  Future<bool> signOut() => _run(_repository.signOut);

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
    return !state.hasError;
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

String authErrorMessage(Object? error) {
  if (error is GoogleSignInException &&
      error.code == GoogleSignInExceptionCode.canceled) {
    return 'Google sign-in was cancelled.';
  }

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
      case 'missing-google-token':
        return 'Google authentication could not be completed.';
      case 'account-exists-with-different-credential':
        return 'This email is already associated with another sign-in method.';
    }
  }

  if (error is UnsupportedError) {
    return 'Google Sign-In is unavailable on this platform.';
  }
return error?.toString() ?? 'Unknown authentication error.';
}