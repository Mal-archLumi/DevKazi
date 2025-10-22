import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class SignUpParams {
  final String name;
  final String email;
  final String password;

  SignUpParams({
    required this.name,
    required this.email,
    required this.password,
  });
}

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> execute(SignUpParams params) async {
    return await repository.signUp(params.name, params.email, params.password);
  }
}
