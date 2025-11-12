import 'package:dartz/dartz.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/core/network/api_client.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<Either<Failure, UserModel>> getCurrentUser();
  Future<Either<Failure, UserModel>> updateProfile(Map<String, dynamic> data);
  Future<Either<Failure, UserModel>> addSkills(List<String> skills);
  Future<Either<Failure, UserModel>> removeSkills(List<String> skills);
  Future<Either<Failure, void>> deleteAccount();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient client;

  UserRemoteDataSourceImpl({required this.client});

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      final response = await client.get('/users/profile', requiresAuth: true);

      if (response.isSuccess && response.data != null) {
        return Right(UserModel.fromJson(response.data!));
      } else {
        return Left(
          ServerFailure(response.message ?? 'Failed to get user profile'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await client.put(
        '/users/profile',
        data: data,
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return Right(UserModel.fromJson(response.data!));
      } else {
        return Left(
          ServerFailure(response.message ?? 'Failed to update profile'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> addSkills(List<String> skills) async {
    try {
      final response = await client.put(
        '/users/skills',
        data: {'skills': skills},
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return Right(UserModel.fromJson(response.data!));
      } else {
        return Left(ServerFailure(response.message ?? 'Failed to add skills'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> removeSkills(List<String> skills) async {
    try {
      final response = await client.delete(
        '/users/skills',
        data: {'skills': skills},
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return Right(UserModel.fromJson(response.data!));
      } else {
        return Left(
          ServerFailure(response.message ?? 'Failed to remove skills'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final response = await client.delete(
        '/users/profile',
        requiresAuth: true,
      );

      if (response.isSuccess) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(response.message ?? 'Failed to delete account'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
