import 'package:flutter/material.dart';

/// SimpleAppsPG Obsidian Dark Theme for MotoAngleHUD
/// High-contrast Racing Red (#EF4444) and Neon Green (#00E676) on Deep Obsidian (#0B0F19).
/// No network GoogleFonts calls.
class AppColors {
  static const Color bgDark = Color(0xFF0B0F19);
  static const Color surfaceCard = Color(0xFF161F30);
  static const Color surfaceElevated = Color(0xFF1E293B);
  static const Color borderSubtle = Color(0xFF243046);
  static const Color borderHighContrast = Color(0xFF334155);

  // Racing & Telemetry Accent Tokens
  static const Color racingRed = Color(0xFFEF4444);
  static const Color neonGreen = Color(0xFF00E676);
  static const Color cautionAmber = Color(0xFFFFD600);
  static const Color electricCyan = Color(0xFF38BDF8);

  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);

  static Color getLeanZoneColor(double absLeanDeg) {
    if (absLeanDeg < 30.0) {
      return neonGreen;
    } else if (absLeanDeg < 45.0) {
      return cautionAmber;
    } else {
      return racingRed;
    }
  }
}

class AppTheme {
  static const Color primary = Color(0xFFEF4444); // Racing Red
  static const Color primaryDark = Color(0xFFB91C1C);
  static const Color accent = Color(0xFF00E676); // Neon Green
  static const Color cyan = Color(0xFF38BDF8);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFD600);
  static const Color error = Color(0xFFEF4444);

  static const Color darkBg = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkCard = Color(0xFF161F30);
  static const Color darkBorder = Color(0xFF243046);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.racingRed,
        secondary: AppColors.neonGreen,
        error: AppColors.racingRed,
        surface: AppColors.surfaceCard,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgDark,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonGreen, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
      ),
    );
  }
}
