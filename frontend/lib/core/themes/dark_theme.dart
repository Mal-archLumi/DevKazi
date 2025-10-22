import 'package:flutter/material.dart';
import 'color_palette.dart';
import 'text_styles.dart';

class DarkTheme {
  // Dark Theme - Minimalist, Google-inspired dark theme for Devkazi
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        // Primary colors (using blue #1976D2 for consistency with light theme)
        primary: ColorPalette.secondary700, // #1976D2
        onPrimary: Colors.white,
        primaryContainer: ColorPalette.secondary800, // Darker blue
        onPrimaryContainer: ColorPalette.neutral100,

        // Secondary colors
        secondary: ColorPalette.secondary500, // #2196F3
        onSecondary: Colors.white,
        secondaryContainer: ColorPalette.secondary900,
        onSecondaryContainer: ColorPalette.neutral200,

        // Surface colors
        surface: const Color(0xFF121212), // Standard dark background
        onSurface: ColorPalette.neutral100, // Near-white text
        surfaceContainerHighest: ColorPalette.neutral900,
        onSurfaceVariant: ColorPalette.neutral400,

        // Error colors
        error: ColorPalette.error400,
        onError: Colors.white,
        errorContainer: ColorPalette.error700,
        onErrorContainer: ColorPalette.neutral200,

        // Outline colors
        outline: ColorPalette.neutral600,
        outlineVariant: ColorPalette.neutral700,

        // Shadow
        shadow: Colors.black.withValues(alpha: 0.2),
      ),

      // Text Theme (same as light theme for consistency)
      textTheme: TextTheme(
        displayLarge: TextStyles.displayLarge.copyWith(
          color: ColorPalette.neutral100,
        ),
        displayMedium: TextStyles.displayMedium.copyWith(
          color: ColorPalette.neutral100,
        ),
        displaySmall: TextStyles.displaySmall.copyWith(
          color: ColorPalette.neutral100,
        ),
        headlineLarge: TextStyles.headlineLarge.copyWith(
          color: ColorPalette.neutral100,
        ),
        headlineMedium: TextStyles.headlineMedium.copyWith(
          color: ColorPalette.neutral100,
        ),
        headlineSmall: TextStyles.headlineSmall.copyWith(
          color: ColorPalette.neutral100,
        ),
        titleLarge: TextStyles.titleLarge.copyWith(
          color: ColorPalette.neutral100,
        ),
        titleMedium: TextStyles.titleMedium.copyWith(
          color: ColorPalette.neutral100,
        ),
        titleSmall: TextStyles.titleSmall.copyWith(
          color: ColorPalette.neutral100,
        ),
        bodyLarge: TextStyles.bodyLarge.copyWith(
          color: ColorPalette.neutral200,
        ),
        bodyMedium: TextStyles.bodyMedium.copyWith(
          color: ColorPalette.neutral200,
        ),
        bodySmall: TextStyles.bodySmall.copyWith(
          color: ColorPalette.neutral300,
        ),
        labelLarge: TextStyles.labelLarge.copyWith(
          color: ColorPalette.neutral100,
        ),
        labelMedium: TextStyles.labelMedium.copyWith(
          color: ColorPalette.neutral100,
        ),
        labelSmall: TextStyles.labelSmall.copyWith(
          color: ColorPalette.neutral300,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.secondary700, // #1976D2
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: TextStyles.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorPalette.secondary700,
          textStyle: TextStyles.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: const BorderSide(color: ColorPalette.secondary700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColorPalette.secondary700,
          textStyle: TextStyles.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorPalette.neutral900,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.neutral600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.neutral600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorPalette.secondary700,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.error400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.error400, width: 2),
        ),
        labelStyle: TextStyles.bodyMedium.copyWith(
          color: ColorPalette.neutral400,
        ),
        hintStyle: TextStyles.bodyMedium.copyWith(
          color: ColorPalette.neutral500,
        ),
        errorStyle: TextStyles.bodySmall.copyWith(color: ColorPalette.error400),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: Color(0xFF1E1E1E), // Darker surface for cards
        elevation: 2,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: ColorPalette.neutral100,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyles.titleLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: ColorPalette.neutral100,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF121212),
        selectedItemColor: ColorPalette.secondary700,
        unselectedItemColor: ColorPalette.neutral400,
      ),

      // Dialog Theme
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
