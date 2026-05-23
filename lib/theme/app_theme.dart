import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leaflens/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.mediumGreen,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.offWhite,

      // Typography
      textTheme: GoogleFonts.interTextTheme().copyWith(
        // Sensor values (big numbers)
        headlineLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w700, fontSize: 36,
        ),
        // Gauge values
        headlineMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w800, fontSize: 28,
        ),
        // Card titles
        titleLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w700, fontSize: 20,
        ),
        // Body
        bodyLarge: GoogleFonts.roboto(
          fontWeight: FontWeight.w500, fontSize: 16,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontWeight: FontWeight.w400, fontSize: 14,
        ),
        bodySmall: GoogleFonts.roboto(
          fontWeight: FontWeight.w400, fontSize: 12,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600, fontSize: 16,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        hintStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Bottom Navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
