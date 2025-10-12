import 'package:flutter/material.dart';
import 'package:frontend/core/constants/route_constants.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/auth/presentation/pages/signup_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.login:
        return _buildRoute(const LoginPage(), settings);

      case RouteConstants.signUp:
        return _buildRoute(const SignUpPage(), settings);

      // Add other routes as needed
      // case RouteConstants.home:
      //   return _buildRoute(const HomePage(), settings);

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

  // Helper methods for common routes
  static Route<dynamic> get loginRoute =>
      generateRoute(RouteSettings(name: RouteConstants.login));

  static Route<dynamic> get signUpRoute =>
      generateRoute(RouteSettings(name: RouteConstants.signUp));
}
