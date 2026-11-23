import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/verification_screen.dart';
import '../../features/reviews/presentation/screens/review_screen.dart';
import '../../features/reviews/presentation/screens/seller_reviews_screen.dart';
import '../temp_home_screen.dart';

/// Screens anyone can open without being logged in.
const _publicRoutes = {'/welcome', '/login', '/signup', '/forgot-password'};

/// App navigation. Sends users to the right screen depending on their login state.
final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final refresh = _AuthRefreshNotifier(authRepository.authStateChanges());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/welcome',
    refreshListenable: refresh,
    redirect: (context, state) {
      final user = authRepository.currentUser;
      final location = state.matchedLocation;
      final onPublicRoute = _publicRoutes.contains(location);

      // Not logged in: only public screens are allowed.
      if (user == null) return onPublicRoute ? null : '/welcome';
      // Logged in but email not verified: must verify first.
      if (!user.emailVerified) return location == '/verify-email' ? null : '/verify-email';
      // Logged in and verified: skip the auth screens.
      if (onPublicRoute || location == '/verify-email') return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/verify-email', builder: (context, state) => const EmailVerificationScreen()),
      GoRoute(path: '/home', builder: (context, state) => const TempHomeScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/profile/edit', builder: (context, state) => const EditProfileScreen()),
      GoRoute(path: '/profile/verify', builder: (context, state) => const VerificationScreen()),
      GoRoute(
        path: '/orders/:orderId/review',
        builder: (context, state) => ReviewScreen(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: '/users/:uid/reviews',
        builder: (context, state) => SellerReviewsScreen(sellerId: state.pathParameters['uid']!),
      ),
    ],
  );
});

/// Tells the router to re-check redirects whenever the user logs in or out.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}