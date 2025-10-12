import 'package:flutter/material.dart';
import 'package:frontend/core/constants/route_constants.dart';
import 'package:frontend/core/services/navigation/app_router.dart';
import 'package:frontend/core/services/navigation/navigation_service.dart';
import 'package:frontend/core/themes/app_theme.dart';
import 'package:frontend/core/themes/dark_theme.dart';
import 'package:frontend/core/themes/theme_manager.dart';

class DevKaziApp extends StatefulWidget {
  const DevKaziApp({super.key});

  @override
  State<DevKaziApp> createState() => _DevKaziAppState();
}

class _DevKaziAppState extends State<DevKaziApp> {
  final NavigationService _navigationService = NavigationService();

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return ValueListenableBuilder<ThemeData>(
      valueListenable: themeManager.themeNotifier,
      builder: (context, themeData, child) {
        return MaterialApp(
          title: 'DevKazi',
          theme: AppTheme.light,
          darkTheme: DarkTheme.dark,
          themeMode: themeManager.themeMode == AppThemeMode.system
              ? ThemeMode.system
              : (themeManager.isDarkMode ? ThemeMode.dark : ThemeMode.light),

          // Routing configuration
          navigatorKey: _navigationService.navigatorKey,
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: RouteConstants.login,

          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
