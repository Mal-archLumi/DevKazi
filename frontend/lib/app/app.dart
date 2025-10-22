import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/route_constants.dart';
import 'package:frontend/core/services/navigation/app_router.dart';
import 'package:frontend/core/services/navigation/navigation_service.dart';
import 'package:frontend/core/themes/app_theme.dart';
import 'package:frontend/core/themes/dark_theme.dart';
import 'package:frontend/core/themes/theme_manager.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/domain/use_cases/login_usecase.dart';
import 'package:frontend/features/auth/domain/use_cases/signup_usecase.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

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

    return MultiProvider(
      providers: [
        // Provide AuthRepository
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(), // You'll need to create this
        ),

        // Provide Use Cases
        Provider<LoginUseCase>(
          create: (context) => LoginUseCase(context.read<AuthRepository>()),
        ),
        Provider<SignUpUseCase>(
          create: (context) => SignUpUseCase(context.read<AuthRepository>()),
        ),

        // Provide AuthCubit
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(
            loginUseCase: context.read<LoginUseCase>(),
            signUpUseCase: context.read<SignUpUseCase>(),
            authRepository: context.read<AuthRepository>(),
          ),
        ),
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
                : (themeManager.isDarkMode ? ThemeMode.dark : ThemeMode.light),

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
  }
}
