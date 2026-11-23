
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'package:flutter/services.dart';

/// Entry point of the ReUse Marketplace application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

try {
  final content = await rootBundle.loadString('.env');
  debugPrint('ENV asset found: ${content.length} characters');
} catch (e) {
  debugPrint('ENV asset loading failed: $e');
}  

  // 1. Load environment variables.
await dotenv.load(fileName: 'config.env');

debugPrint('Supabase environment loaded successfully');
  // 2. Initialize Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Read Supabase configuration from .env.
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabasePublishableKey =
      dotenv.env['SUPABASE_PUBLISHABLE_KEY'];

  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabasePublishableKey == null ||
      supabasePublishableKey.isEmpty) {
    throw StateError(
      'Missing Supabase configuration in .env file.',
    );
  }

  // 4. Initialize Supabase using Firebase Authentication.
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
    accessToken: () async {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return null;
      }

      // Retrieve the Firebase ID token for Supabase requests.
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

/// Root widget of the ReUse Marketplace application.
class ReuseMarketplaceApp extends StatelessWidget {
  const ReuseMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReUse Marketplace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F5E3B),
        ),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'ReUse Marketplace: Firebase and Supabase initialized',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
