import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/user_repository.dart';

class LogoutUseCase {
  final UserRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}
