
import 'package:flutter/material.dart';

import '../listings/presentation/screens/marketplace_home_screen.dart';
import '../listings/presentation/screens/create_edit_listing_screen.dart';
import '../listings/presentation/screens/my_listings_screen.dart';
import '../looking_for/presentation/screens/looking_for_screen.dart';
import '../looking_for/presentation/screens/my_requests_screen.dart';

class MarketplaceRoutes {
  MarketplaceRoutes._();

  static const String home = '/marketplace';
  static const String sell = '/sell';
  static const String myListings = '/my-listings';
  static const String lookingFor = '/looking-for';
  static const String myRequests = '/my-requests';

  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const MarketplaceHomeScreen(),
        sell: (_) => const CreateEditListingScreen(),
        myListings: (_) => const MyListingsScreen(),
        lookingFor: (_) => const LookingForScreen(),
        myRequests: (_) => const MyRequestsScreen(),
      };
}
