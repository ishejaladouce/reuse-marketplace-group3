import 'package:flutter/material.dart';
import 'screens/shell.dart';
import 'theme/app_theme.dart';

void main() => runApp(const ReuseApp());

class ReuseApp extends StatelessWidget {
  const ReuseApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Reuse Marketplace',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const Shell(),
      );
}
