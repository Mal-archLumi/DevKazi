// lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/common/loaders/loading_overlay.dart';
import 'package:frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/presentation/pages/signup_page.dart';
import 'package:frontend/features/auth/presentation/widgets/email_field.dart';
import 'package:frontend/features/auth/presentation/widgets/password_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  String? _errorMessage;
  late AnimationController _errorAnimationController;
  late Animation<double> _errorAnimation;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ValueNotifier<bool> rememberMe = ValueNotifier<bool>(false);

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
    emailController.dispose();
    passwordController.dispose();
    rememberMe.dispose();
    _errorAnimationController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    _errorAnimationController.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _hideError();
      }
    });
  }

  void _hideError() {
    _errorAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  void _handleLogin(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      _showError('Please enter your email address');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    if (password.isEmpty) {
      _showError('Please enter your password');
      return;
    }

    if (password.length < 8) {
      _showError('Password must be at least 8 characters long');
      return;
    }

    if (!mounted) return;
    context.read<AuthCubit>().login(email, password);
  }

  void _handleGoogleSignIn(BuildContext context) {
    context.read<AuthCubit>().loginWithGoogle();
  }

  void _navigateToSignUp(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const SignUpPage(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _navigateToForgotPassword(BuildContext context) {
    Navigator.pushNamed(context, '/forgot-password');
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

  Widget _buildLoginForm(bool isLoading) {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo
                    Image.asset(
                      'assets/images/logos/devkazi.png',
                      width: 90,
                      height: 90,
                    ),

                    const SizedBox(height: 12),

                    // Gradient title
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

                    // 🟢 Box model card container
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

                              EmailField(
                                controller: emailController,
                                hintText: 'Email',
                              ),
                              const SizedBox(height: 16),
                              PasswordField(
                                controller: passwordController,
                                hintText: 'Password',
                              ),

                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ValueListenableBuilder<bool>(
                                    valueListenable: rememberMe,
                                    builder: (context, value, _) {
                                      return Row(
                                        children: [
                                          Checkbox(
                                            value: value,
                                            onChanged: isLoading
                                                ? null
                                                : (v) => rememberMe.value =
                                                      v ?? false,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                          const Text("Remember me"),
                                        ],
                                      );
                                    },
                                  ),
                                  GestureDetector(
                                    onTap: isLoading
                                        ? null
                                        : () => _navigateToForgotPassword(
                                            context,
                                          ),
                                    child: Text(
                                      "Forgot password?",
                                      style: TextStyle(
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Sign In button
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => _handleLogin(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      62,
                                      124,
                                      107,
                                    ),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Sign in',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Divider
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

                              // Google button
                              SizedBox(
                                height: 50,
                                child: OutlinedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => _handleGoogleSignIn(context),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
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

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: isLoading
                              ? null
                              : () => _navigateToSignUp(context),
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Terms
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "By continuing, you agree to DevKazi’s Terms of Service and Privacy Policy.",
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/teams');
            }
          });
        } else if (state is AuthError) {
          if (mounted) _showError(state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return _buildLoginForm(isLoading);
      },
    );
  }
}
