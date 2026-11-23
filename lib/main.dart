
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // 2. Initialize Supabase Storage with Firebase authentication.
  await Supabase.initialize(
    url: 'https://nbizkkncorkhnzrplvto.supabase.co',
    publishableKey: 'sb_publishable_9z2eMo8Mpy3AYoDZo3nPtA_FE10KrHY',
    accessToken: () async {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return null;
      }

      return await user.getIdToken();
    },
  );

  // 3. Start the application with Riverpod.
  runApp(
    const ProviderScope(
      child: ReuseMarketplaceApp(),
    ),
  );
}
