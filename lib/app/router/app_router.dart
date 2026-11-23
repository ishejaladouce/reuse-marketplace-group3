
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Authentication
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';

// Profile
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/verification_screen.dart';

// Marketplace
import '../../features/listings/presentation/screens/marketplace_home_screen.dart';
import '../../features/listings/presentation/screens/listing_details_screen.dart';
import '../../features/listings/presentation/screens/create_edit_listing_screen.dart';
import '../../features/listings/presentation/screens/my_listings_screen.dart';
import '../../features/marketplace/presentation/screens/explore_screen.dart';

// Looking For
import '../../features/looking_for/presentation/screens/looking_for_screen.dart';
import '../../features/looking_for/presentation/screens/my_requests_screen.dart';

// Messages and orders
import '../../screens/messages_screen.dart';
import '../../screens/orders_screen.dart';

// Reviews
import '../../features/reviews/presentation/screens/review_screen.dart';
import '../../features/reviews/presentation/screens/seller_reviews_screen.dart';

// Shared navigation
import 'main_navigation_shell.dart';

const _publicRoutes = {
  '/welcome',
  '/login',
  '/signup',
  '/forgot-password',
};

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  final refresh = _AuthRefreshNotifier(
    authRepository.authStateChanges(),
  );

  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: '/welcome',
    refreshListenable: refresh,

    redirect: (context, state) {
      final user = authRepository.currentUser;
      final location = state.matchedLocation;
      final onPublicRoute = _publicRoutes.contains(location);

      if (user == null) {
        return onPublicRoute ? null : '/welcome';
      }

      if (!user.emailVerified) {
        return location == '/verify-email'
            ? null
            : '/verify-email';
      }

      if (onPublicRoute || location == '/verify-email') {
        return '/home';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/home',
      ),

      // Authentication
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) =>
            const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) =>
            const EmailVerificationScreen(),
      ),

      // Main five-tab marketplace
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(
            navigationShell: navigationShell,
          );
        },
        branches: [
          // 1. HOME
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) =>
                    const MarketplaceHomeScreen(),
                routes: [
                  GoRoute(
                    path: 'listings/:listingId',
                    builder: (context, state) =>
                        ListingDetailsScreen(
                      listingId:
                          state.pathParameters['listingId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. EXPLORE
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) =>
                    const ExploreScreen(),
                routes: [
                  GoRoute(
                    path: 'looking-for',
                    builder: (context, state) =>
                        const LookingForScreen(),
                  ),
                ],
              ),
            ],
          ),

          // 3. SELL
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sell',
                builder: (context, state) =>
                    const CreateEditListingScreen(),
              ),
            ],
          ),

          // 4. MESSAGES
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/messages',
                builder: (context, state) =>
                    const MessagesScreen(),
              ),
            ],
          ),

          // 5. PROFILE
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) =>
                    const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Marketplace routes
      GoRoute(
        path: '/marketplace',
        redirect: (context, state) => '/home',
      ),
      GoRoute(
        path: '/listings/:listingId',
        redirect: (context, state) =>
            '/home/listings/${state.pathParameters['listingId']}',
      ),
      GoRoute(
        path: '/my-listings',
        builder: (context, state) =>
            const MyListingsScreen(),
      ),

      // Orders - Firestore-backed purchases and sales
      GoRoute(
        path: '/orders',
        builder: (context, state) =>
            const OrdersScreen(),
      ),

      // Looking For
      GoRoute(
        path: '/looking-for',
        redirect: (context, state) =>
            '/explore/looking-for',
      ),
      GoRoute(
        path: '/my-requests',
        builder: (context, state) =>
            const MyRequestsScreen(),
      ),

      // Reviews
      GoRoute(
        path: '/orders/:orderId/review',
        builder: (context, state) =>
            ReviewScreen(
          orderId: state.pathParameters['orderId']!,
        ),
      ),
      GoRoute(
        path: '/users/:sellerId/reviews',
        builder: (context, state) =>
            SellerReviewsScreen(
          sellerId: state.pathParameters['sellerId']!,
        ),
      ),

      // Profile management
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) =>
            const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/verify',
        builder: (context, state) =>
            const VerificationScreen(),
      ),
    ],
  );

  ref.onDispose(router.dispose);

  return router;
});

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Stream<Object?> stream) {
    _subscription = stream.listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
