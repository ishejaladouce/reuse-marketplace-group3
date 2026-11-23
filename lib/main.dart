
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'firebase_options.dart';

/// Entry point for the ReUse Marketplace application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase Authentication and Firestore.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Load the Supabase configuration.
  await dotenv.load(fileName: 'config.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabasePublishableKey =
      dotenv.env['SUPABASE_PUBLISHABLE_KEY'];

  // 3. Validate environment configuration.
  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabasePublishableKey == null ||
      supabasePublishableKey.isEmpty) {
    throw StateError(
      'Missing Supabase configuration in config.env.',
    );
  }

  // 4. Initialize Supabase Storage with Firebase authentication.
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
    accessToken: () async {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return null;
      }

      return await user.getIdToken();
    },
  );

  // 5. Start the application with Riverpod.
  runApp(
    const ProviderScope(
      child: ReuseMarketplaceApp(),
    ),
  );
}
