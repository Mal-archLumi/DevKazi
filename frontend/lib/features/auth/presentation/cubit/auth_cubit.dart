// lib/features/auth/presentation/cubit/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/entities/tokens_entity.dart'; // Add this
import 'package:frontend/features/auth/domain/use_cases/login_usecase.dart';
import 'package:frontend/features/auth/domain/use_cases/signup_usecase.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final AuthRepository authRepository;

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
        // Verify token is still valid - handle Either type properly
        final userResult = await authRepository.getCurrentUser();
        userResult.fold(
          (failure) {
            print('Failed to load current user: ${failure.message}');
            // Keep as AuthInitial if loading fails
          },
          (user) {
            emit(AuthAuthenticated(user));
          },
        );
      }
    } catch (e) {
      print('Error loading saved auth state: $e');
      // Keep as AuthInitial if loading fails
    }
  }

  // ... rest of your existing methods remain the same
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
        emit(AuthAuthenticated(user));
      });
    } catch (error) {
      emit(AuthError('Google sign-in failed. Please try again.'));
    }
  }

  void logout() {
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
}
