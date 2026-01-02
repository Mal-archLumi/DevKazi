import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/projects/domain/entities/project_entity.dart';
import 'package:frontend/features/projects/domain/repositories/project_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddIdeaUseCase {
  final ProjectRepository repository;

  AddIdeaUseCase(this.repository);

  Future<Either<Failure, ProjectEntity>> call({
    required String projectId,
    required String title,
    required String description,
  }) async {
    try {
      final project = await repository.addIdea(
        projectId: projectId,
        title: title,
        description: description,
      );
      return Right(project);
    } on Failure catch (e) {
      return Left(e);
    }
  }
}
