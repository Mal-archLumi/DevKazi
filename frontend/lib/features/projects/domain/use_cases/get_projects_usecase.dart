import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/projects/domain/entities/project_entity.dart';
import 'package:frontend/features/projects/domain/repositories/project_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetProjectsUseCase {
  final ProjectRepository repository;

  GetProjectsUseCase(this.repository);

  Future<Either<Failure, List<ProjectEntity>>> call(String teamId) async {
    try {
      final projects = await repository.getProjectsByTeam(teamId);
      return Right(projects);
    } on Failure catch (e) {
      return Left(e);
    }
  }
}
