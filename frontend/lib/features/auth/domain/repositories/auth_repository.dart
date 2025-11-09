// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/entities/tokens_entity.dart'; // Add this import

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> signUp(
    String name,
    String email,
    String password,
  );
  Future<Either<Failure, UserEntity>> signUpWithGoogle(String idToken);
  Future<Either<Failure, UserEntity>> loginWithGoogle();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, void>> updateUserProfile(UserEntity user);
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();

  // ADD THIS MISSING METHOD:
  Future<TokensEntity> getTokens();
}
