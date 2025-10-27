import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/widgets/common/loaders/loading_overlay.dart';
import 'package:frontend/features/auth/presentation/widgets/email_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Text editing controller
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = true}) {
    setState(() {
      if (isError) {
        _errorMessage = message;
        _successMessage = null;
      } else {
        _successMessage = message;
        _errorMessage = null;
      }
    });
    _animationController.forward();

    // Auto-hide message after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _hideMessage();
      }
    });
  }

  void _hideMessage() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _errorMessage = null;
          _successMessage = null;
        });
      }
    });
  }

  Future<void> _handleResetPassword(BuildContext context) async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Please enter your email address');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showMessage('Please enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['BACKEND_URL']}/api/v1/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _showMessage(
          data['message'] ?? 'Password reset link sent to your email',
          isError: false,
        );
      } else {
        final errorData = jsonDecode(response.body);
        _showMessage(
          errorData['message'] ??
              'Failed to send reset link. Please try again.',
        );
      }
    } catch (error) {
      _showMessage('Network error. Please check your connection.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToLogin(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildMessageWidget() {
    if (_errorMessage == null && _successMessage == null) {
      return const SizedBox.shrink();
    }

    final isError = _errorMessage != null;
    final message = isError ? _errorMessage : _successMessage;

    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.5),
          end: Offset.zero,
        ).animate(_animation),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isError ? Colors.red.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isError ? Colors.red.shade200 : Colors.green.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: (isError ? Colors.red.shade100 : Colors.green.shade100)
                    .withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline,
                color: isError ? Colors.red.shade600 : Colors.green.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message!,
                  style: TextStyle(
                    color: isError
                        ? Colors.red.shade700
                        : Colors.green.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _hideMessage,
                child: Icon(
                  Icons.close_rounded,
                  color: isError ? Colors.red.shade400 : Colors.green.shade400,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushReplacementNamed(context, '/login');
      },
      child: LoadingOverlay(
        isLoading: _isLoading,
        child: Scaffold(
          backgroundColor: theme
              .colorScheme
              .surface, // Uses Google Grey 50 (light) or dark surface
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
                              color: Colors.green[700], // Google Green
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: 'Connect. ',
                            style: TextStyle(
                              color: const Color(0xFF1565C0), // Google Blue 700
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: 'Create.',
                            style: TextStyle(
                              color: Colors.orange[300], // Google Orange
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Message widget (error or success)
                    _buildMessageWidget(),

                    // Email field
                    EmailField(controller: emailController, hintText: 'Email'),

                    const SizedBox(height: 24),

                    // Reset Password Button
                    SizedBox(
                      width: double.infinity,
                      height: 53,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _handleResetPassword(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Google White
                          foregroundColor: Colors.black87, // Google Grey 800
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
                        child: const Text('Send Reset Link'),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Back to Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Back to ",
                          style: TextStyle(
                            color: Colors.grey.shade700, // Google Grey 600
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () => _navigateToLogin(context),
                          child: Text(
                            'Sign in',
                            style: TextStyle(
                              color: const Color(0xFF1565C0), // Google Blue 700
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Terms and privacy
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.grey.shade600, // Google Grey 600
                            fontSize: 12,
                          ),
                          children: [
                            const TextSpan(
                              text: 'By continuing, you agree to DevKazi\'s ',
                            ),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: const Color(
                                  0xFF1565C0,
                                ), // Google Blue 700
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: const Color(
                                  0xFF1565C0,
                                ), // Google Blue 700
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
