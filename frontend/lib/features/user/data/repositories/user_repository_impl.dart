import 'package:dartz/dartz.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../data_sources/user_remote_data_source.dart';
import '../data_sources/user_local_data_source.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final AuthRepository authRepository;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authRepository,
  });

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      // Try to get from local cache first for instant display
      final cachedUser = await localDataSource.getCachedUser();

      // Always fetch fresh data from API
      final result = await remoteDataSource.getCurrentUser();

      return result.fold(
        (failure) {
          // If API fails but we have cached data, use it
          if (cachedUser != null) {
            return Right(cachedUser.toEntity());
          }
          return Left(failure);
        },
        (userModel) async {
          // Get tokens from auth repository and merge
          final tokens = await authRepository.getTokens();
          final userWithTokens = userModel.mergeWithAuthData(
            accessToken: tokens.$1 ?? '',
            refreshToken: tokens.$2 ?? '',
          );

          // Cache the updated user
          await localDataSource.cacheUser(userWithTokens);
          return Right(userWithTokens.toEntity());
        },
      );
    } catch (e) {
      // If everything fails, try to return cached user
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }
      return Left(
        ServerFailure('Failed to load user profile: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? bio,
    String? education,
    List<String>? skills,
    bool? isProfilePublic,
  }) async {
    try {
      final data = {
        if (name != null) 'name': name,
        if (bio != null) 'bio': bio,
        if (education != null) 'education': education,
        if (skills != null) 'skills': skills,
        if (isProfilePublic != null) 'isProfilePublic': isProfilePublic,
      };

      final result = await remoteDataSource.updateProfile(data);
      return result.fold((failure) => Left(failure), (userModel) async {
        // Get current user to preserve tokens
        final currentUser = await localDataSource.getCachedUser();
        final updatedUser = userModel.mergeWithAuthData(
          accessToken: currentUser?.accessToken ?? '',
          refreshToken: currentUser?.refreshToken ?? '',
        );

        await localDataSource.cacheUser(updatedUser);
        return Right(updatedUser.toEntity());
      });
    } catch (e) {
      return Left(ServerFailure('Failed to update profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> addSkills(List<String> skills) async {
    try {
      final result = await remoteDataSource.addSkills(skills);
      return result.fold((failure) => Left(failure), (userModel) async {
        final currentUser = await localDataSource.getCachedUser();
        final updatedUser = userModel.mergeWithAuthData(
          accessToken: currentUser?.accessToken ?? '',
          refreshToken: currentUser?.refreshToken ?? '',
        );

        await localDataSource.cacheUser(updatedUser);
        return Right(updatedUser.toEntity());
      });
    } catch (e) {
      return Left(ServerFailure('Failed to add skills: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> removeSkills(List<String> skills) async {
    try {
      final result = await remoteDataSource.removeSkills(skills);
      return result.fold((failure) => Left(failure), (userModel) async {
        final currentUser = await localDataSource.getCachedUser();
        final updatedUser = userModel.mergeWithAuthData(
          accessToken: currentUser?.accessToken ?? '',
          refreshToken: currentUser?.refreshToken ?? '',
        );

        await localDataSource.cacheUser(updatedUser);
        return Right(updatedUser.toEntity());
      });
    } catch (e) {
      return Left(ServerFailure('Failed to remove skills: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final result = await remoteDataSource.deleteAccount();
      return result.fold((failure) => Left(failure), (_) async {
        await _clearAllUserData();
        return const Right(null);
      });
    } catch (e) {
      return Left(ServerFailure('Failed to delete account: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _clearAllUserData();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to logout: ${e.toString()}'));
    }
  }

  // Private method to clear all user data consistently
  Future<void> _clearAllUserData() async {
    try {
      // Clear local user data
      await localDataSource.clearAllData();

      // Clear auth data (tokens)
      await authRepository.logout();

      // Clear any other cached data if needed
      // Add additional cleanup here if necessary
    } catch (e) {
      // Log the error but don't fail the logout process
      print('Error during logout cleanup: $e');
    }
  }
}
