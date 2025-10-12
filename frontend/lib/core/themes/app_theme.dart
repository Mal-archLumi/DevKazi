import 'package:flutter/material.dart';
import 'color_palette.dart';
import 'text_styles.dart';

class AppTheme {
  // Light Theme - Modern, clean light theme
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        // Primary colors
        primary: ColorPalette.primary500,
        onPrimary: Colors.white,
        primaryContainer: ColorPalette.primary50,
        onPrimaryContainer: ColorPalette.primary900,

        // Secondary colors
        secondary: ColorPalette.secondary500,
        onSecondary: Colors.white,
        secondaryContainer: ColorPalette.secondary50,
        onSecondaryContainer: ColorPalette.secondary900,

        // Surface colors
        surface: Colors.white,
        onSurface: ColorPalette.neutral900,
        surfaceContainerHighest: ColorPalette.neutral50,
        onSurfaceVariant: ColorPalette.neutral700,

        // Error colors
        error: ColorPalette.error500,
        onError: Colors.white,
        errorContainer: ColorPalette.error50,
        onErrorContainer: ColorPalette.error700,

        // Outline colors
        outline: ColorPalette.neutral300,
        outlineVariant: ColorPalette.neutral200,

        // Shadow
        // ignore: deprecated_member_use
        shadow: ColorPalette.neutral900.withOpacity(0.1),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyles.displayLarge,
        displayMedium: TextStyles.displayMedium,
        displaySmall: TextStyles.displaySmall,
        headlineLarge: TextStyles.headlineLarge,
        headlineMedium: TextStyles.headlineMedium,
        headlineSmall: TextStyles.headlineSmall,
        titleLarge: TextStyles.titleLarge,
        titleMedium: TextStyles.titleMedium,
        titleSmall: TextStyles.titleSmall,
        bodyLarge: TextStyles.bodyLarge,
        bodyMedium: TextStyles.bodyMedium,
        bodySmall: TextStyles.bodySmall,
        labelLarge: TextStyles.labelLarge,
        labelMedium: TextStyles.labelMedium,
        labelSmall: TextStyles.labelSmall,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.primary500,
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
          foregroundColor: ColorPalette.primary500,
          textStyle: TextStyles.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: const BorderSide(color: ColorPalette.primary500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColorPalette.primary500,
          textStyle: TextStyles.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorPalette.primary500,
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
          color: ColorPalette.neutral600,
        ),
        hintStyle: TextStyles.bodyMedium.copyWith(
          color: ColorPalette.neutral500,
        ),
        errorStyle: TextStyles.bodySmall.copyWith(color: ColorPalette.error500),
      ),

      // Card Theme - Using CardThemeData (modern syntax)
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ColorPalette.neutral900,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyles.titleLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: ColorPalette.primary500,
        unselectedItemColor: ColorPalette.neutral500,
      ),

      // Dialog Theme - Using DialogThemeData (modern syntax)
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
