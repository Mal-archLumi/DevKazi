import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/injection_container.dart'; // ADD THIS IMPORT
import 'package:frontend/core/constants/route_constants.dart';
import 'package:frontend/core/services/navigation/app_router.dart';
import 'package:frontend/core/services/navigation/navigation_service.dart';
import 'package:frontend/core/themes/app_theme.dart';
import 'package:frontend/core/themes/dark_theme.dart';
import 'package:frontend/core/themes/theme_manager.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/teams/presentation/blocs/teams/teams_cubit.dart';

class DevKaziApp extends StatefulWidget {
  const DevKaziApp({super.key});

  @override
  State<DevKaziApp> createState() => _DevKaziAppState();
}

class _DevKaziAppState extends State<DevKaziApp> {
  final NavigationService _navigationService = NavigationService();
  final Future _initDependencies =
      initDependencies(); // INITIALIZE DEPENDENCIES

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return FutureBuilder(
      future: _initDependencies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(create: (context) => getIt<AuthCubit>()),
            BlocProvider<TeamsCubit>(create: (context) => getIt<TeamsCubit>()),
          ],
          child: ValueListenableBuilder<ThemeData>(
            valueListenable: themeManager.themeNotifier,
            builder: (context, themeData, child) {
              return MaterialApp(
                title: 'DevKazi',
                theme: AppTheme.light,
                darkTheme: DarkTheme.dark,
                themeMode: themeManager.themeMode == AppThemeMode.system
                    ? ThemeMode.system
                    : (themeManager.isDarkMode
                          ? ThemeMode.dark
                          : ThemeMode.light),

                // Routing configuration
                navigatorKey: _navigationService.navigatorKey,
                onGenerateRoute: AppRouter.generateRoute,
                initialRoute: RouteConstants.splash,

                debugShowCheckedModeBanner: false,

                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(1.0)),
                    child: child!,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
