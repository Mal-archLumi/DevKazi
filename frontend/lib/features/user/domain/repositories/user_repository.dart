import 'package:dartz/dartz.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? bio,
    String? education,
    List<String>? skills,
    bool? isProfilePublic,
  });
  Future<Either<Failure, UserEntity>> addSkills(List<String> skills);
  Future<Either<Failure, UserEntity>> removeSkills(List<String> skills);
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, void>> logout();
}
