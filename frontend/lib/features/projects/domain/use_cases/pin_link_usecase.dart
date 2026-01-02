import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/projects/domain/entities/project_entity.dart';
import 'package:frontend/features/projects/domain/repositories/project_repository.dart';
import 'package:fpdart/fpdart.dart';

class PinLinkUseCase {
  final ProjectRepository repository;

  PinLinkUseCase(this.repository);

  Future<Either<Failure, ProjectEntity>> call({
    required String projectId,
    required String title,
    required String url,
  }) async {
    try {
      final project = await repository.pinLink(
        projectId: projectId,
        title: title,
        url: url,
      );
      return Right(project);
    } on Failure catch (e) {
      return Left(e);
    }
  }
}
