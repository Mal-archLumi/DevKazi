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
  // Text editing controllers
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
    // Clear previous error
    errorMessage.value = null;

    // Validate name
    final name = nameController.text.trim();
    if (name.isEmpty) {
      errorMessage.value = 'Please enter your name';
      return;
    }

    if (name.length < 2) {
      errorMessage.value = 'Name must be at least 2 characters long';
      return;
    }

    if (name.length > 50) {
      errorMessage.value = 'Name cannot exceed 50 characters';
      return;
    }

    // Validate email
    final email = emailController.text.trim();
    if (email.isEmpty) {
      errorMessage.value = 'Please enter your email address';
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      errorMessage.value = 'Please enter a valid email address';
      return;
    }

    // Validate password
    final password = passwordController.text;
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
          'Password must contain at least one lowercase letter, one uppercase letter, and one number';
      return;
    }

    // Validate confirm password
    if (confirmPasswordController.text.isEmpty) {
      errorMessage.value = 'Please confirm your password';
      return;
    }

    if (!agreeToTerms.value) {
      errorMessage.value =
          'Please agree to the Terms of Service and Privacy Policy';
      return;
    }

    if (password != confirmPasswordController.text) {
      errorMessage.value = 'Passwords do not match';
      return;
    }

    // Call AuthCubit signUp with name
    context.read<AuthCubit>().signUp(name, email, password);
  }

  void _handleGoogleSignUp() {
    // Clear previous error
    errorMessage.value = null;

    if (!agreeToTerms.value) {
      errorMessage.value =
          'Please agree to the Terms of Service and Privacy Policy';
      return;
    }

    // Use AuthCubit for Google Sign-In
    context.read<AuthCubit>().loginWithGoogle();
  }

  void _navigateToSignIn() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildSignUpForm(bool isLoading) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: LoadingOverlay(
        isLoading: isLoading,
        child: Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Logo
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Image.asset(
                        'assets/images/logos/devkazi.png',
                        width: 100,
                        height: 100,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // DevKazi title with gradient
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.green, Colors.blue, Colors.orange],
                      ).createShader(bounds),
                      child: const Text(
                        'DevKazi',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Code. Connect. Create.
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

                    const SizedBox(height: 20),

                    // Error message
                    ValueListenableBuilder<String?>(
                      valueListenable: errorMessage,
                      builder: (context, error, child) {
                        if (error == null) {
                          return const SizedBox(height: 20);
                        }

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(8),
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
                                onTap: () => errorMessage.value = null,
                                child: Icon(
                                  Icons.close,
                                  color: Colors.red.shade700,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Name field
                    NameField(
                      controller: nameController,
                      hintText: 'Full Name',
                    ),

                    const SizedBox(height: 16),

                    // Email field
                    EmailField(controller: emailController, hintText: 'Email'),

                    const SizedBox(height: 16),

                    // Password field
                    PasswordField(
                      controller: passwordController,
                      hintText: 'Password',
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password field
                    PasswordField(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                    ),

                    const SizedBox(height: 16),

                    // Agree to terms
                    ValueListenableBuilder<bool>(
                      valueListenable: agreeToTerms,
                      builder: (context, value, child) {
                        return Row(
                          children: [
                            Checkbox(
                              value: value,
                              onChanged: isLoading
                                  ? null
                                  : (newValue) {
                                      agreeToTerms.value = newValue ?? false;
                                    },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontSize: 14),
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
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
                      width: double.infinity,
                      height: 53,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 1,
                          shadowColor: Colors.black12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: const Text('Sign up'),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Divider with "or"
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Google Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: isLoading ? null : _handleGoogleSignUp,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/logos/google_g.png',
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 12),
                            const Text('Continue with Google'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Sign in link
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
                              color: Colors.blue[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
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
