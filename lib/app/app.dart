
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    as flutter_localizations;

import 'router/app_router.dart';
import 'theme/app_colors.dart';

/// Root widget: theme and navigation for the whole app.
class ReuseMarketplaceApp extends ConsumerWidget {
  const ReuseMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Reuse Marketplace',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),

      // Explicitly use Flutter's standard localization delegates.
      localizationsDelegates: const [
        flutter_localizations.GlobalMaterialLocalizations.delegate,
        flutter_localizations.GlobalWidgetsLocalizations.delegate,
        flutter_localizations.GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(64, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
