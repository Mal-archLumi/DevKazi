// features/teams/presentation/blocs/browse_teams/browse_teams_cubit.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/teams/domain/entities/team_entity.dart';
import 'package:frontend/features/teams/domain/use_cases/get_all_teams_usecase.dart';
import 'package:frontend/features/teams/domain/use_cases/join_team_usecase.dart';

part 'browse_teams_state.dart';

class BrowseTeamsCubit extends Cubit<BrowseTeamsState> {
  final GetAllTeamsUseCase getAllTeams;
  final JoinTeamUseCase joinTeamUseCase;

  BrowseTeamsCubit({required this.getAllTeams, required this.joinTeamUseCase})
    : super(BrowseTeamsState.initial());

  Future<void> loadAllTeams() async {
    emit(state.copyWith(status: BrowseTeamsStatus.loading));

    final result = await getAllTeams();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BrowseTeamsStatus.error,
          errorMessage: _mapFailureToMessage(failure),
        ),
      ),
      (teams) => emit(
        state.copyWith(
          status: BrowseTeamsStatus.loaded,
          teams: teams,
          filteredTeams: teams,
        ),
      ),
    );
  }

  Future<void> joinTeam(String teamId) async {
    final result = await joinTeamUseCase(teamId);

    result.fold(
      (failure) =>
          emit(state.copyWith(errorMessage: _mapFailureToMessage(failure))),
      (success) {
        final updatedTeams = state.teams.map((team) {
          if (team.id == teamId) {
            return team.copyWith(isMember: true);
          }
          return team;
        }).toList();

        emit(state.copyWith(teams: updatedTeams, filteredTeams: updatedTeams));
      },
    );
  }

  void searchTeams(String query) {
    if (query.isEmpty) {
      emit(state.copyWith(filteredTeams: state.teams, isSearching: false));
      return;
    }

    final filtered = state.teams.where((team) {
      return team.name.toLowerCase().contains(query.toLowerCase()) ||
          (team.description?.toLowerCase().contains(query.toLowerCase()) ??
              false);
    }).toList();

    emit(state.copyWith(filteredTeams: filtered, isSearching: true));
  }

  void refresh() {
    loadAllTeams();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Failed to load teams. Please try again.';
      case NetworkFailure:
        return 'No internet connection. Please check your connection.';
      default:
        return 'An unexpected error occurred';
    }
  }
}
