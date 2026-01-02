// features/teams/domain/usecases/get_join_requests_usecase.dart
import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import '../entities/join_request_entity.dart';
import '../repositories/team_repository.dart';

class GetJoinRequestsUseCase {
  final TeamRepository repository;

  GetJoinRequestsUseCase(this.repository);

  Future<Either<Failure, List<JoinRequestEntity>>> call(String teamId) async {
    return repository.getJoinRequests(teamId);
  }
}
