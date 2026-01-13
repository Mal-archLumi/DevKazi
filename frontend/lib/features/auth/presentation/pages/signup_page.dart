// lib/features/auth/presentation/pages/signup_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/auth/presentation/widgets/email_field.dart';
import 'package:frontend/features/auth/presentation/widgets/password_field.dart';
import 'package:frontend/features/auth/presentation/widgets/name_field.dart';
import 'package:frontend/core/widgets/common/loaders/loading_overlay.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/core/constants/route_constants.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  String? _errorMessage;
  late AnimationController _errorAnimationController;
  late Animation<double> _errorAnimation;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final ValueNotifier<bool> agreeToTerms = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _errorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _errorAnimation = CurvedAnimation(
      parent: _errorAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    agreeToTerms.dispose();
    _errorAnimationController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    _errorAnimationController.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _hideError();
    });
  }

  void _hideError() {
    _errorAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() => _errorMessage = null);
      }
    });
  }

  void _handleSignUp() {
    _hideError();
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty) return _showError('Please enter your name');
    if (name.length < 2) {
      return _showError('Name must be at least 2 characters long');
    }
    if (email.isEmpty) return _showError('Please enter your email address');
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return _showError('Please enter a valid email address');
    }
    if (password.isEmpty) return _showError('Please enter your password');
    if (password.length < 8) {
      return _showError('Password must be at least 8 characters long');
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])').hasMatch(password)) {
      return _showError(
        'Password must contain lowercase, uppercase, and a number',
      );
    }
    if (confirmPassword.isEmpty) {
      return _showError('Please confirm your password');
    }
    if (password != confirmPassword) {
      return _showError('Passwords do not match');
    }
    if (!agreeToTerms.value) {
      return _showError(
        'Please agree to the Terms of Service and Privacy Policy',
      );
    }

    context.read<AuthCubit>().signUp(name, email, password);
  }

  void _handleGoogleSignUp() {
    _hideError();
    if (!agreeToTerms.value) {
      return _showError(
        'Please agree to the Terms of Service and Privacy Policy',
      );
    }
    context.read<AuthCubit>().loginWithGoogle();
  }

  void _navigateToSignIn(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _errorAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.5),
          end: Offset.zero,
        ).animate(_errorAnimation),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.red.shade100.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _hideError,
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.red.shade400,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm(bool isLoading) {
    // Removed PopScope(canPop: false) → much better UX
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo & title (same as before)
                  Image.asset(
                    'assets/images/logos/devkazi.png',
                    width: 90,
                    height: 90,
                  ),
                  const SizedBox(height: 12),

                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.green, Colors.blue, Colors.orange],
                    ).createShader(bounds),
                    child: const Text(
                      'DevKazi',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    "Code. Connect. Create.",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildErrorWidget(),

                            const Text(
                              "Create your account",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 24),

                            NameField(
                              controller: nameController,
                              hintText: 'Full Name',
                            ),
                            const SizedBox(height: 16),
                            EmailField(
                              controller: emailController,
                              hintText: 'Email',
                            ),
                            const SizedBox(height: 16),
                            PasswordField(
                              controller: passwordController,
                              hintText: 'Password',
                            ),
                            const SizedBox(height: 16),
                            PasswordField(
                              controller: confirmPasswordController,
                              hintText: 'Confirm Password',
                            ),

                            const SizedBox(height: 20),

                            ValueListenableBuilder<bool>(
                              valueListenable: agreeToTerms,
                              builder: (context, value, child) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      value: value,
                                      onChanged: isLoading
                                          ? null
                                          : (v) =>
                                                agreeToTerms.value = v ?? false,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                          children: [
                                            const TextSpan(
                                              text: 'I agree to the ',
                                            ),
                                            TextSpan(
                                              text: 'Terms of Service',
                                              style: TextStyle(
                                                color: Colors.blue[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const TextSpan(text: ' and '),
                                            TextSpan(
                                              text: 'Privacy Policy',
                                              style: TextStyle(
                                                color: Colors.blue[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _handleSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Sign up',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey.shade400),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    "or",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Colors.grey.shade400),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: isLoading
                                    ? null
                                    : _handleGoogleSignUp,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade400),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/logos/google_g.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text("Continue with Google"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: isLoading
                            ? null
                            : () => _navigateToSignIn(context),
                        child: Text(
                          "Sign in",
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "By continuing, you agree to DevKazi's Terms of Service and Privacy Policy.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Small delay is usually not needed, but kept for smoothness
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              // This line already prevents going back
              Navigator.pushReplacementNamed(context, '/teams');
            }
          });
        } else if (state is AuthError) {
          if (mounted) _showError(state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return _buildSignUpForm(isLoading);
      },
    );
  }
}
