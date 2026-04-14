import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _seed = Color(0xFFD56DFF);
  static const _darkBackground = Color(0xFF07030D);
  static const _darkSurface = Color(0xFF140A1F);
  static const _lightBackground = Color(0xFFFAF5FF);
  static const _lightSurface = Color(0xFFFFFBFF);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
      surface: _lightSurface,
    );
    return _buildTheme(
      scheme: scheme,
      scaffoldBackground: _lightBackground,
      appBarBackground: _lightSurface,
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
      surface: _darkSurface,
    );
    return _buildTheme(
      scheme: scheme,
      scaffoldBackground: _darkBackground,
      appBarBackground: const Color(0xFF11071A),
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme scheme,
    required Color scaffoldBackground,
    required Color appBarBackground,
  }) {
    final textTheme = TextTheme(
      displaySmall: GoogleFonts.oswald(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
      headlineMedium: GoogleFonts.oswald(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
      titleLarge: GoogleFonts.ibmPlexSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.ibmPlexSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.ibmPlexSans(fontSize: 16, height: 1.35),
      bodyMedium: GoogleFonts.ibmPlexSans(fontSize: 14, height: 1.4),
      labelLarge: GoogleFonts.ibmPlexSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        titleTextStyle: GoogleFonts.oswald(
          color: scheme.onSurface,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      cardColor: scheme.surface,
      dividerColor: scheme.outlineVariant,
    );
  }
}
