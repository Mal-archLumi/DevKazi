// lib/features/auth/presentation/cubit/auth_cubit.dart - UPDATED
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/use_cases/login_usecase.dart';
import 'package:frontend/features/auth/domain/use_cases/signup_usecase.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/core/services/token_refresh_service.dart'; // Add this

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final AuthRepository authRepository;
  final TokenRefreshService _tokenService = TokenRefreshService(); // Add this
  Timer? _tokenRefreshTimer; // Add this

  AuthCubit({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    // Load saved auth state on initialization
    _loadSavedAuthState();
  }

  Future<void> _loadSavedAuthState() async {
    try {
      final tokens = await authRepository.getTokens();
      if (tokens.accessToken.isNotEmpty) {
        // Verify token is still valid using refresh service
        final validToken = await _tokenService.getValidAccessToken();

        if (validToken != null) {
          // Get user data
          final userResult = await authRepository.getCurrentUser();
          userResult.fold(
            (failure) {
              print('Failed to load current user: ${failure.message}');
              // Keep as AuthInitial if loading fails
            },
            (user) {
              _startTokenRefreshTimer(); // Start refresh timer
              emit(AuthAuthenticated(user));
            },
          );
        } else {
          print('Token is not valid, requiring re-login');
        }
      }
    } catch (e) {
      print('Error loading saved auth state: $e');
      // Keep as AuthInitial if loading fails
    }
  }

  // ... rest of your existing methods remain the same until after success cases
  Future<void> login(String email, String password) async {
    if (state is AuthLoading) return;

    emit(AuthLoading());

    try {
      final result = await loginUseCase.execute(
        LoginParams(email: email, password: password),
      );

      result.fold(
        (failure) {
          emit(AuthError(failure.message));
        },
        (user) async {
          if (user.accessToken.isEmpty || user.refreshToken.isEmpty) {
            emit(AuthError('Authentication failed: No tokens received'));
            return;
          }

          await authRepository.saveTokens(user.accessToken, user.refreshToken);
          _startTokenRefreshTimer(); // ADD THIS LINE
          emit(AuthAuthenticated(user));
        },
      );
    } catch (e) {
      emit(
        AuthError('Login failed. Please check your credentials and try again.'),
      );
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    if (state is AuthLoading) return;

    emit(AuthLoading());

    try {
      final result = await signUpUseCase.execute(
        SignUpParams(name: name, email: email, password: password),
      );

      result.fold(
        (failure) {
          emit(AuthError(failure.message));
        },
        (user) async {
          if (user.accessToken.isEmpty || user.refreshToken.isEmpty) {
            emit(AuthError('Registration failed: No tokens received'));
            return;
          }

          await authRepository.saveTokens(user.accessToken, user.refreshToken);
          _startTokenRefreshTimer(); // ADD THIS LINE
          emit(AuthAuthenticated(user));
        },
      );
    } catch (e) {
      emit(AuthError('Registration failed. Please try again.'));
    }
  }

  Future<void> loginWithGoogle() async {
    if (state is AuthLoading) return;

    emit(AuthLoading());
    try {
      final result = await authRepository.loginWithGoogle();

      result.fold((failure) => emit(AuthError(failure.message)), (user) async {
        if (user.accessToken.isEmpty || user.refreshToken.isEmpty) {
          emit(AuthError('Google sign-in failed: No tokens received'));
          return;
        }

        await authRepository.saveTokens(user.accessToken, user.refreshToken);
        _startTokenRefreshTimer(); // ADD THIS LINE
        emit(AuthAuthenticated(user));
      });
    } catch (error) {
      emit(AuthError('Google sign-in failed. Please try again.'));
    }
  }

  Future<void> signUpWithGoogle(String idToken) async {
    if (state is AuthLoading) return;

    emit(AuthLoading());
    try {
      final result = await authRepository.signUpWithGoogle(idToken);
      result.fold((failure) => emit(AuthError(failure.message)), (user) async {
        if (user.accessToken.isEmpty || user.refreshToken.isEmpty) {
          emit(AuthError('Google sign-in failed: No tokens received'));
          return;
        }

        await authRepository.saveTokens(user.accessToken, user.refreshToken);
        _startTokenRefreshTimer(); // ADD THIS LINE
        emit(AuthAuthenticated(user));
      });
    } catch (error) {
      emit(AuthError('Google sign-in failed. Please try again.'));
    }
  }

  // UPDATED logout method
  void logout() async {
    _stopTokenRefreshTimer(); // Stop the refresh timer

    try {
      await authRepository.clearTokens();
    } catch (e) {
      print('Error clearing tokens: $e');
    }

    emit(AuthInitial());
  }

  void clearError() {
    if (state is AuthError) {
      emit(AuthInitial());
    }
  }

  void resetState() {
    emit(AuthInitial());
  }

  // ADD THESE NEW METHODS for token refresh management
  void _startTokenRefreshTimer() {
    _stopTokenRefreshTimer(); // Stop any existing timer

    // Check token every 5 minutes (adjust as needed)
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 5), (
      timer,
    ) async {
      try {
        final currentState = state;
        if (currentState is AuthAuthenticated) {
          final token = await _tokenService.getValidAccessToken();
          if (token == null) {
            // Token refresh failed - log out
            debugPrint('🔴 Token refresh failed in timer, logging out...');
            logout();
          } else {
            debugPrint('🔄 Token refresh check completed successfully');
          }
        }
      } catch (e) {
        debugPrint('🔴 Error in token refresh timer: $e');
      }
    });
  }

  void _stopTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  @override
  Future<void> close() {
    _stopTokenRefreshTimer();
    return super.close();
  }
}
