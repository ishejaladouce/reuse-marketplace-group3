import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens taken from the Reuse Marketplace Figma prototype:
/// deep forest green, warm cream background, soft mint/sand tints, clean geometric sans.
class AppColors {
  static const green = Color(0xFF175C42); // primary buttons, selected states, "Reuse" logo
  static const greenDark = Color(0xFF0F4632);
  static const mint = Color(0xFFE6F2EA); // trust banners, verified tint
  static const cream = Color(0xFFF8F4EC); // screen background
  static const sand = Color(0xFFF6E3A1); // icon accent (Looking For)
  static const blush = Color(0xFFF8E1DC); // alerts, price drop
  static const surface = Colors.white;
  static const ink = Color(0xFF1A2B24);
  static const muted = Color(0xFF7A8680);
  static const border = Color(0xFFE6E1D6);
  static const star = Color(0xFFF2B01E);
  static const danger = Color(0xFFC0392B);
}

class AppTheme {
  static ThemeData get light {
    // Manrope is the closest match to the prototype's rounded geometric sans.
    final base = GoogleFonts.manropeTextTheme();
    final text = base.apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        primary: AppColors.green,
        surface: AppColors.surface,
      ),
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.ink,
        centerTitle: false,
        titleTextStyle: GoogleFonts.manrope(
            fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.green,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.green, width: 1.5)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.green : AppColors.border),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      dividerColor: AppColors.border,
    );
  }
}
