import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:organizer/app/theme/app_color.dart';

class AppTheme {
  AppTheme._();

  static ThemeData _baseThemeForSeed(Color seed) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColor.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
          background: AppColor.background,
          surface: AppColor.surface,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          bodyLarge: TextStyle(color: AppColor.textPrimary),
          bodyMedium: TextStyle(color: AppColor.textPrimary),
          titleLarge: TextStyle(color: AppColor.textPrimary),
          titleMedium: TextStyle(color: AppColor.textPrimary),
          labelLarge: TextStyle(color: AppColor.textPrimary),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          foregroundColor: AppColor.textPrimary,
        ),
        cardTheme: CardThemeData(
          color: AppColor.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColor.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: seed, width: 1.2),
          ),
          hintStyle: TextStyle(color: AppColor.textMuted),
          labelStyle: TextStyle(color: AppColor.textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            elevation: 0,
            backgroundColor: seed,
            foregroundColor: Colors.white,
          ),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: AppColor.surface,
          modalBackgroundColor: AppColor.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
        ),
      );

  // Default themes
  static ThemeData lightTheme = _baseThemeForSeed(AppColor.primary);
  static ThemeData darkTheme = lightTheme;

  // Create a theme based on a personality seed color
  static ThemeData themeForPersonality(String personality) {
    switch (personality.toLowerCase()) {
      case 'ocean':
        return _baseThemeForSeed(const Color(0xff2563EB));
      case 'forest':
        return _baseThemeForSeed(const Color(0xff15803D));
      case 'sunset':
        return _baseThemeForSeed(const Color(0xffF97316));
      case 'aurora':
        return _baseThemeForSeed(const Color(0xff7C3AED));
      case 'noir':
        return _baseThemeForSeed(const Color(0xff111827));
      default:
        return _baseThemeForSeed(AppColor.primary);
    }
  }

}
