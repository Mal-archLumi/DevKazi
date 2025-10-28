// splash_page.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/route_constants.dart';
import 'package:frontend/core/injection_container.dart'; // Add this import
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

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
    // Check if user is already authenticated with better logging
    final authRepository = getIt<AuthRepository>();

    print('🟡 Splash: Checking for existing token...');
    final accessToken = await authRepository.getAccessToken();

    print('🟡 Splash: Token exists: ${accessToken != null}');

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      if (accessToken != null) {
        print('🟢 Splash: User is logged in, navigating to teams');
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(RouteConstants.teams, (route) => false);
      } else {
        print('🔴 Splash: No token found, navigating to login');
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
