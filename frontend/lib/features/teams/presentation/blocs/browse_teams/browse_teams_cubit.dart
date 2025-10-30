// features/teams/presentation/blocs/browse_teams/browse_teams_cubit.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/teams/domain/entities/team_entity.dart';
import 'package:frontend/features/teams/domain/use_cases/get_all_teams_usecase.dart';
import 'package:frontend/features/teams/domain/use_cases/get_user_teams_usecase.dart';
import 'package:frontend/features/teams/domain/use_cases/join_team_usecase.dart';

part 'browse_teams_state.dart';

class BrowseTeamsCubit extends Cubit<BrowseTeamsState> {
  final GetAllTeamsUseCase getAllTeams;
  final GetUserTeamsUseCase getUserTeams;
  final JoinTeamUseCase joinTeamUseCase;

  BrowseTeamsCubit({
    required this.getAllTeams,
    required this.getUserTeams,
    required this.joinTeamUseCase,
  }) : super(BrowseTeamsState.initial());

  Future<void> loadAllTeams() async {
    emit(state.copyWith(status: BrowseTeamsStatus.loading));

    try {
      // Get user's teams first
      final userTeamsResult = await getUserTeams();

      userTeamsResult.fold(
        (failure) {
          // If we can't get user teams, show error
          emit(
            state.copyWith(
              status: BrowseTeamsStatus.error,
              errorMessage: 'Failed to load user teams',
            ),
          );
        },
        (userTeams) async {
          // Now get ALL teams
          final allTeamsResult = await getAllTeams();

          allTeamsResult.fold(
            (failure) {
              emit(
                state.copyWith(
                  status: BrowseTeamsStatus.error,
                  errorMessage: _mapFailureToMessage(failure),
                ),
              );
            },
            (allTeams) {
              // Filter out teams that user is already a member of
              final userTeamIds = userTeams.map((team) => team.id).toSet();
              final browseTeams = allTeams
                  .where((team) => !userTeamIds.contains(team.id))
                  .toList();

              print(
                '🟢 Filtered ${allTeams.length} total teams to ${browseTeams.length} browse teams',
              );
              print(
                '🟢 User has ${userTeams.length} teams, showing ${browseTeams.length} other teams',
              );

              emit(
                state.copyWith(
                  status: BrowseTeamsStatus.loaded,
                  teams: browseTeams,
                  filteredTeams: browseTeams,
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BrowseTeamsStatus.error,
          errorMessage: 'Unexpected error: $e',
        ),
      );
    }
  }

  // Rest of your cubit methods remain the same...
  Future<void> joinTeam(String teamId) async {
    final result = await joinTeamUseCase(teamId);

    result.fold(
      (failure) =>
          emit(state.copyWith(errorMessage: _mapFailureToMessage(failure))),
      (success) {
        // Remove the joined team from the list
        final updatedTeams = state.teams
            .where((team) => team.id != teamId)
            .toList();
        final updatedFilteredTeams = state.filteredTeams
            .where((team) => team.id != teamId)
            .toList();

        emit(
          state.copyWith(
            teams: updatedTeams,
            filteredTeams: updatedFilteredTeams,
          ),
        );
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
