// lib/features/auth/presentation/pages/signup_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final ValueNotifier<bool> agreeToTerms = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    agreeToTerms.dispose();
    errorMessage.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    errorMessage.value = null;
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty) {
      errorMessage.value = 'Please enter your name';
      return;
    }
    if (name.length < 2) {
      errorMessage.value = 'Name must be at least 2 characters long';
      return;
    }
    if (email.isEmpty) {
      errorMessage.value = 'Please enter your email address';
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      errorMessage.value = 'Please enter a valid email address';
      return;
    }
    if (password.isEmpty) {
      errorMessage.value = 'Please enter your password';
      return;
    }
    if (password.length < 8) {
      errorMessage.value = 'Password must be at least 8 characters long';
      return;
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])').hasMatch(password)) {
      errorMessage.value =
          'Password must contain lowercase, uppercase, and a number';
      return;
    }
    if (confirmPassword.isEmpty) {
      errorMessage.value = 'Please confirm your password';
      return;
    }
    if (password != confirmPassword) {
      errorMessage.value = 'Passwords do not match';
      return;
    }
    if (!agreeToTerms.value) {
      errorMessage.value =
          'Please agree to the Terms of Service and Privacy Policy';
      return;
    }

    context.read<AuthCubit>().signUp(name, email, password);
  }

  void _handleGoogleSignUp() {
    errorMessage.value = null;
    if (!agreeToTerms.value) {
      errorMessage.value =
          'Please agree to the Terms of Service and Privacy Policy';
      return;
    }
    context.read<AuthCubit>().loginWithGoogle();
  }

  void _navigateToSignIn() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  Widget _buildSignUpForm(bool isLoading) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) SystemNavigator.pop();
      },
      child: LoadingOverlay(
        isLoading: isLoading,
        child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 36,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo + app name
                        Image.asset(
                          'assets/images/logos/devkazi.png',
                          width: 90,
                          height: 90,
                        ),
                        const SizedBox(height: 16),
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
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Code. ',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: 'Connect. ',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 21, 88, 143),
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: 'Create.',
                                style: TextStyle(
                                  color: Colors.orange[300],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),

                        // 🟢 Box container
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
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

                              // Error message
                              ValueListenableBuilder<String?>(
                                valueListenable: errorMessage,
                                builder: (context, error, child) {
                                  if (error == null) return const SizedBox();
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.red.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red.shade700,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            error,
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              errorMessage.value = null,
                                          child: Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              // Input fields
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

                              // Checkbox for terms
                              ValueListenableBuilder<bool>(
                                valueListenable: agreeToTerms,
                                builder: (context, value, child) {
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        value: value,
                                        onChanged: isLoading
                                            ? null
                                            : (newValue) {
                                                agreeToTerms.value =
                                                    newValue ?? false;
                                              },
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
                              const SizedBox(height: 24),

                              // Sign Up Button
                              SizedBox(
                                height: 53,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _handleSignUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Sign up',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade300,
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'or',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade300,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Google Button
                              SizedBox(
                                height: 53,
                                child: OutlinedButton(
                                  onPressed: isLoading
                                      ? null
                                      : _handleGoogleSignUp,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.grey.shade400,
                                      width: 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
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
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Footer link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: isLoading ? null : _navigateToSignIn,
                              child: Text(
                                'Sign in',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
          Navigator.pushReplacementNamed(context, RouteConstants.teams);
        } else if (state is AuthError) {
          errorMessage.value = state.message;
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return _buildSignUpForm(isLoading);
      },
    );
  }
}
