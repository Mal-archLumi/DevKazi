import 'package:flutter/material.dart';
import 'color_palette.dart';
import 'text_styles.dart';

class DarkTheme {
  // Dark Theme - Modern, sleek dark theme
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        // Primary colors
        primary: ColorPalette.primary400,
        onPrimary: ColorPalette.neutral900,
        primaryContainer: ColorPalette.primary800,
        onPrimaryContainer: ColorPalette.primary100,

        // Secondary colors
        secondary: ColorPalette.secondary400,
        onSecondary: ColorPalette.neutral900,
        secondaryContainer: ColorPalette.secondary800,
        onSecondaryContainer: ColorPalette.secondary100,

        // Surface colors
        surface: ColorPalette.neutral900,
        onSurface: ColorPalette.neutral50,
        surfaceContainerHighest: ColorPalette.neutral800,
        onSurfaceVariant: ColorPalette.neutral200,

        // Error colors
        error: ColorPalette.error500,
        onError: Colors.white,
        errorContainer: ColorPalette.error800,
        onErrorContainer: ColorPalette.error100,

        // Outline colors
        outline: ColorPalette.neutral700,
        outlineVariant: ColorPalette.neutral600,

        // Shadow
        shadow: Colors.black.withOpacity(0.4),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyles.displayLarge.copyWith(
          color: ColorPalette.neutral50,
        ),
        displayMedium: TextStyles.displayMedium.copyWith(
          color: ColorPalette.neutral50,
        ),
        displaySmall: TextStyles.displaySmall.copyWith(
          color: ColorPalette.neutral50,
        ),
        headlineLarge: TextStyles.headlineLarge.copyWith(
          color: ColorPalette.neutral50,
        ),
        headlineMedium: TextStyles.headlineMedium.copyWith(
          color: ColorPalette.neutral50,
        ),
        headlineSmall: TextStyles.headlineSmall.copyWith(
          color: ColorPalette.neutral50,
        ),
        titleLarge: TextStyles.titleLarge.copyWith(
          color: ColorPalette.neutral50,
        ),
        titleMedium: TextStyles.titleMedium.copyWith(
          color: ColorPalette.neutral50,
        ),
        titleSmall: TextStyles.titleSmall.copyWith(
          color: ColorPalette.neutral50,
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
          color: ColorPalette.neutral50,
        ),
        labelMedium: TextStyles.labelMedium.copyWith(
          color: ColorPalette.neutral50,
        ),
        labelSmall: TextStyles.labelSmall.copyWith(
          color: ColorPalette.neutral50,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.primary400,
          foregroundColor: ColorPalette.neutral900,
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
          foregroundColor: ColorPalette.primary400,
          textStyle: TextStyles.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: const BorderSide(color: ColorPalette.primary400),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColorPalette.primary400,
          textStyle: TextStyles.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorPalette.neutral800,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.neutral700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.neutral700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorPalette.primary400,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.error500),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.error500, width: 2),
        ),
        labelStyle: TextStyles.bodyMedium.copyWith(
          color: ColorPalette.neutral400,
        ),
        hintStyle: TextStyles.bodyMedium.copyWith(
          color: ColorPalette.neutral500,
        ),
        errorStyle: TextStyles.bodySmall.copyWith(color: ColorPalette.error500),
      ),

      // Card Theme - Using CardThemeData (modern syntax)
      cardTheme: const CardThemeData(
        color: ColorPalette.neutral800,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: ColorPalette.neutral900,
        foregroundColor: ColorPalette.neutral50,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyles.titleLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ColorPalette.neutral900,
        selectedItemColor: ColorPalette.primary400,
        unselectedItemColor: ColorPalette.neutral400,
      ),

      // Dialog Theme - Using DialogThemeData (modern syntax)
      dialogTheme: const DialogThemeData(
        backgroundColor: ColorPalette.neutral800,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
