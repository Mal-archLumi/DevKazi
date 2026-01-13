// splash_page.dart - UPDATED with token refresh
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/route_constants.dart';
import 'package:frontend/core/injection_container.dart';
import 'package:frontend/core/services/token_refresh_service.dart'; // Add this

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Use TokenRefreshService instead of directly checking token
    final tokenService = TokenRefreshService();

    print('🟡 Splash: Checking for valid token...');
    final validToken = await tokenService.getValidAccessToken();

    print('🟡 Splash: Valid token exists: ${validToken != null}');

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      if (validToken != null) {
        print('🟢 Splash: User has valid token, navigating to teams');
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(RouteConstants.teams, (route) => false);
      } else {
        print('🔴 Splash: No valid token, navigating to login');
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(RouteConstants.login, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo - using your actual logo
            _buildAppLogo(),
            const SizedBox(height: 24),
            // App Name
            _buildAppName(),
            const SizedBox(height: 16),
            // Loading Indicator
            _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Image.asset(
      'assets/images/logos/devkazi.png',
      width: 120,
      height: 120,
    );
  }

  Widget _buildAppName() {
    return Text(
      'DevKazi',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
