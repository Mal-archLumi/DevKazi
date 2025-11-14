import 'package:flutter/material.dart';
import 'package:frontend/core/constants/route_constants.dart';
import 'package:frontend/features/splash/presentation/pages/splash_page.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/auth/presentation/pages/signup_page.dart';
import 'package:frontend/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:frontend/features/teams/presentation/blocs/create_team/create_team_cubit.dart';
import 'package:frontend/features/teams/presentation/pages/teams_list_page.dart';
import 'package:frontend/features/teams/presentation/pages/create_team_page.dart';
import 'package:frontend/features/notifications/presentation/pages/notifications_page.dart';
import 'package:frontend/features/user/presentation/pages/profile_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/injection_container.dart';
import 'package:frontend/features/teams/presentation/pages/team_details_page.dart';
import 'package:frontend/features/teams/presentation/blocs/team_details/team_details_cubit.dart';
import 'package:frontend/features/teams/domain/entities/team_entity.dart';
import 'package:frontend/features/user/presentation/cubits/user_cubit.dart'; // ADD THIS IMPORT

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.splash:
        return _buildRoute(const SplashPage(), settings);

      case RouteConstants.login:
        return _buildRoute(const LoginPage(), settings);

      case RouteConstants.signUp:
        return _buildRoute(const SignUpPage(), settings);

      case RouteConstants.forgotPassword:
        return _buildRoute(const ForgotPasswordPage(), settings);

      case RouteConstants.home:
      case RouteConstants.teams:
        return _buildRoute(const TeamsListPage(), settings);

      case RouteConstants.createTeam:
        return _buildRoute(
          BlocProvider(
            create: (context) => getIt<CreateTeamCubit>(),
            child: const CreateTeamPage(),
          ),
          settings,
        );

      case RouteConstants.teamDetails:
        final team = settings.arguments as TeamEntity;
        return _buildRoute(
          BlocProvider(
            create: (context) => getIt<TeamDetailsCubit>(),
            child: TeamDetailsPage(team: team),
          ),
          settings,
        );

      case RouteConstants.notifications:
        return _buildRoute(const NotificationsPage(), settings);

      case RouteConstants.profile:
        // Remove BlocProvider from here - UserCubit is provided at app level
        return _buildRoute(const ProfilePage(), settings);

      default:
        return _buildRoute(
          Scaffold(
            body: Center(child: Text('Page not found for ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
