import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/projects/domain/entities/project_entity.dart';
import 'package:frontend/features/projects/domain/repositories/project_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateProjectUseCase {
  final ProjectRepository repository;

  CreateProjectUseCase(this.repository);

  Future<Either<Failure, ProjectEntity>> call({
    required String teamId,
    required String name,
    required String? description,
    required List<ProjectAssignment> assignments,
    required List<TimelinePhase> timeline,
  }) async {
    try {
      final project = await repository.createProject(
        teamId: teamId,
        name: name,
        description: description,
        assignments: assignments,
        timeline: timeline,
      );
      return Right(project);
    } on Failure catch (e) {
      return Left(e);
    }
  }
}
