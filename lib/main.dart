
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for authentication and Firestore.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load Supabase configuration.
  await dotenv.load(fileName: 'config.env');

  // Initialize Supabase Storage with Firebase authentication.
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
    accessToken: () async {
      return FirebaseAuth.instance.currentUser?.getIdToken();
    },
  );

  // Start the application with Riverpod.
  runApp(
    const ProviderScope(
      child: ReuseMarketplaceApp(),
    ),
  );
}
