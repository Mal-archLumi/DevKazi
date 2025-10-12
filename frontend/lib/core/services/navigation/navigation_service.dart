import 'package:flutter/material.dart';
import 'package:frontend/core/constants/route_constants.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => navigatorKey.currentState!;

  Future<T?> navigateTo<T>(String routeName, {Object? arguments}) {
    return _navigator.pushNamed<T>(routeName, arguments: arguments);
  }

  Future<T?> navigateToReplacement<T, TO>(
    String routeName, {
    Object? arguments,
  }) {
    return _navigator.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
    );
  }

  Future<T?> navigateToAndRemoveUntil<T>(
    String routeName, {
    bool Function(Route<dynamic>)? predicate,
  }) {
    return _navigator.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: null,
    );
  }

  void goBack<T>([T? result]) {
    return _navigator.pop<T>(result);
  }

  // Specific route methods
  Future<T?> navigateToLogin<T>() => navigateTo<T>(RouteConstants.login);
  Future<T?> navigateToSignUp<T>() => navigateTo<T>(RouteConstants.signUp);
  Future<T?> navigateToHome<T>() =>
      navigateToAndRemoveUntil<T>(RouteConstants.home);
}
