// lib/features/teams/presentation/blocs/team_details/team_details_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:frontend/features/teams/domain/entities/team_entity.dart';
import 'team_details_state.dart';

class TeamDetailsCubit extends Cubit<TeamDetailsState> {
  TeamDetailsCubit() : super(const TeamDetailsState());

  void setTeam(TeamEntity team) {
    emit(state.copyWith(status: TeamDetailsStatus.loaded, team: team));
  }
}
