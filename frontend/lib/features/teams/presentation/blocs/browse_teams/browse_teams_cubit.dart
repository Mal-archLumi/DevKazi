// features/teams/presentation/blocs/browse_teams/browse_teams_cubit.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/teams/domain/entities/team_entity.dart';
import 'package:frontend/features/teams/domain/use_cases/get_all_teams_usecase.dart';
import 'package:frontend/features/teams/domain/use_cases/get_user_teams_usecase.dart';
import 'package:frontend/features/teams/domain/use_cases/join_team_usecase.dart';
import 'package:frontend/features/teams/domain/use_cases/search_browse_teams_usecase.dart';

part 'browse_teams_state.dart';

class BrowseTeamsCubit extends Cubit<BrowseTeamsState> {
  final GetAllTeamsUseCase getAllTeams;
  final GetUserTeamsUseCase getUserTeams;
  final JoinTeamUseCase joinTeamUseCase;
  final SearchBrowseTeamsUseCase searchBrowseTeams;

  BrowseTeamsCubit({
    required this.getAllTeams,
    required this.getUserTeams,
    required this.joinTeamUseCase,
    required this.searchBrowseTeams,
  }) : super(BrowseTeamsState.initial());

  Future<void> loadAllTeams() async {
    if (isClosed) return;

    emit(state.copyWith(status: BrowseTeamsStatus.loading));

    try {
      // Get user's teams first
      final userTeamsResult = await getUserTeams();

      userTeamsResult.fold(
        (failure) {
          if (!isClosed) {
            emit(
              state.copyWith(
                status: BrowseTeamsStatus.error,
                errorMessage: 'Failed to load user teams',
              ),
            );
          }
        },
        (userTeams) async {
          // Now get ALL teams
          final allTeamsResult = await getAllTeams();

          allTeamsResult.fold(
            (failure) {
              if (!isClosed) {
                emit(
                  state.copyWith(
                    status: BrowseTeamsStatus.error,
                    errorMessage: _mapFailureToMessage(failure),
                  ),
                );
              }
            },
            (allTeams) {
              if (!isClosed) {
                // Filter out teams that user is already a member of
                final userTeamIds = userTeams.map((team) => team.id).toSet();
                final browseTeams = allTeams
                    .where((team) => !userTeamIds.contains(team.id))
                    .toList();

                debugPrint(
                  '🟢 Filtered ${allTeams.length} total teams to ${browseTeams.length} browse teams',
                );

                emit(
                  state.copyWith(
                    status: BrowseTeamsStatus.loaded,
                    teams: browseTeams,
                    filteredTeams: browseTeams,
                  ),
                );
              }
            },
          );
        },
      );
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: BrowseTeamsStatus.error,
            errorMessage: 'Unexpected error: $e',
          ),
        );
      }
    }
  }

  Future<void> searchTeams(String query) async {
    if (query.isEmpty) {
      // When search is cleared, show all browse teams
      emit(state.copyWith(filteredTeams: state.teams, isSearching: false));
      return;
    }

    // Show loading state for search
    emit(state.copyWith(status: BrowseTeamsStatus.loading, isSearching: true));

    try {
      // Use the backend search endpoint for browse teams
      final searchResult = await searchBrowseTeams(query);

      searchResult.fold(
        (failure) {
          emit(
            state.copyWith(
              status: BrowseTeamsStatus.error,
              errorMessage: _mapFailureToMessage(failure),
              isSearching: false,
            ),
          );
        },
        (searchResults) {
          // ADD NAME-ONLY FILTERING
          final searchLower = query.toLowerCase();
          final nameFilteredResults = searchResults.where((team) {
            return team.name.toLowerCase().contains(searchLower);
          }).toList();

          debugPrint(
            '🟢 Browse backend search found ${nameFilteredResults.length} teams (name-only) for: "$query"',
          );

          emit(
            state.copyWith(
              status: BrowseTeamsStatus.loaded,
              filteredTeams: nameFilteredResults,
              isSearching: true,
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('🔴 Browse search error: $e');
      emit(
        state.copyWith(
          status: BrowseTeamsStatus.error,
          errorMessage: 'Search failed: $e',
          isSearching: false,
        ),
      );
    }
  }

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
