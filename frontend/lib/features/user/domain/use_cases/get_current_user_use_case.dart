import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetCurrentUserUseCase {
  final UserRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.getCurrentUser();
  }
}
