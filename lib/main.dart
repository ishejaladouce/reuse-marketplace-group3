import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

/// Entry point of the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: ReuseMarketplaceApp()));
}

/// Root widget of the Reuse Marketplace app.
class ReuseMarketplaceApp extends StatelessWidget {
  const ReuseMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reuse Marketplace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F5E3B)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Reuse Marketplace: Firebase connected'),
        ),
      ),
    );
  }
}