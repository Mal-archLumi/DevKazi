// domain/usecases/create_team_usecase.dart
import 'package:dartz/dartz.dart';
import '/../core/errors/failures.dart';
import '../repositories/team_repository.dart';

class CreateTeamUseCase {
  final TeamRepository repository;

  CreateTeamUseCase(this.repository);

  Future<Either<Failure, void>> call(String name, {String? description}) async {
    return await repository.createTeam(name, description: description);
  }
}
