import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'dark_theme.dart';

enum AppThemeMode { light, dark, system }

class ThemeManager with ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  AppThemeMode _themeMode = AppThemeMode.light;
  final ValueNotifier<ThemeData> _themeNotifier = ValueNotifier<ThemeData>(
    AppTheme.light,
  );

  AppThemeMode get themeMode => _themeMode;

  set themeMode(AppThemeMode mode) {
    _themeMode = mode;
    _updateThemeNotifier();
    notifyListeners();
  }

  ThemeData get currentTheme {
    switch (_themeMode) {
      case AppThemeMode.dark:
        return DarkTheme.dark;
      case AppThemeMode.light:
      case AppThemeMode.system:
        return AppTheme.light;
    }
  }

  bool get isDarkMode => _themeMode == AppThemeMode.dark;

  ValueListenable<ThemeData> get themeNotifier => _themeNotifier;

  void _updateThemeNotifier() {
    _themeNotifier.value = currentTheme;
  }

  void toggleTheme() {
    _themeMode = _themeMode == AppThemeMode.light
        ? AppThemeMode.dark
        : AppThemeMode.light;
    _updateThemeNotifier();
    notifyListeners();
  }
}
