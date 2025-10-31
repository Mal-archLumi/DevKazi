// lib/features/teams/presentation/blocs/team_details/team_details_state.dart
import 'package:frontend/features/teams/domain/entities/team_entity.dart';

enum TeamDetailsStatus { initial, loading, loaded, error }

class TeamDetailsState {
  final TeamDetailsStatus status;
  final TeamEntity? team;
  final String? errorMessage;

  const TeamDetailsState({
    this.status = TeamDetailsStatus.initial,
    this.team,
    this.errorMessage,
  });

  TeamDetailsState copyWith({
    TeamDetailsStatus? status,
    TeamEntity? team,
    String? errorMessage,
  }) {
    return TeamDetailsState(
      status: status ?? this.status,
      team: team ?? this.team,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
