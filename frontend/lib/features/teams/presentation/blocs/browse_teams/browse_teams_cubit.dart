// features/teams/presentation/blocs/browse_teams/browse_teams_cubit.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

    final allTeamsResult = await getAllTeams();

    if (isClosed) return;

    final userTeamsResult = await getUserTeams();

    if (isClosed) return;

    if (allTeamsResult.isLeft()) {
      allTeamsResult.fold((failure) {
        if (!isClosed) {
          emit(
            state.copyWith(
              status: BrowseTeamsStatus.error,
              errorMessage: failure.message,
            ),
          );
        }
      }, (_) {});
      return;
    }

    final List<TeamEntity> allTeams = allTeamsResult.fold(
      (failure) => [],
      (teams) => teams,
    );

    final Set<String> userTeamIds = userTeamsResult.fold((failure) {
      debugPrint('Failed to get user teams: ${failure.message}');
      return <String>{};
    }, (userTeams) => userTeams.map((team) => team.id).toSet());

    debugPrint('🟡 BrowseTeamsCubit: All teams count: ${allTeams.length}');
    debugPrint('🟡 BrowseTeamsCubit: User team IDs: $userTeamIds');

    final List<TeamEntity> browsableTeams = allTeams
        .where((team) => !userTeamIds.contains(team.id))
        .toList();

    debugPrint(
      '🟢 BrowseTeamsCubit: Browsable teams count: ${browsableTeams.length}',
    );

    if (!isClosed) {
      emit(
        state.copyWith(
          status: BrowseTeamsStatus.loaded,
          teams: browsableTeams,
          allTeams: allTeams,
          userTeamIds: userTeamIds,
        ),
      );
    }
  }

  Future<void> searchTeams(String query) async {
    if (isClosed) return;

    if (query.isEmpty) {
      final browsableTeams = state.allTeams
          .where((team) => !state.userTeamIds.contains(team.id))
          .toList();

      emit(
        state.copyWith(
          isSearching: false,
          filteredTeams: [],
          searchQuery: '',
          teams: browsableTeams,
        ),
      );
      return;
    }

    emit(state.copyWith(isSearching: true, searchQuery: query));

    final result = await searchBrowseTeams(query);

    if (isClosed) return;

    result.fold(
      (failure) {
        if (!isClosed) {
          emit(
            state.copyWith(
              status: BrowseTeamsStatus.error,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (teams) {
        if (!isClosed) {
          final filteredSearchResults = teams
              .where((team) => !state.userTeamIds.contains(team.id))
              .toList();

          emit(state.copyWith(filteredTeams: filteredSearchResults));
        }
      },
    );
  }

  Future<void> joinTeam(String teamId) async {
    if (isClosed) return;

    emit(state.copyWith(joiningTeamId: teamId));

    final result = await joinTeamUseCase(teamId);

    if (isClosed) return;

    result.fold(
      (failure) {
        if (!isClosed) {
          // Check if it's a "pending request already exists" error
          final isPendingError =
              failure.message.toLowerCase().contains('pending') == true ||
              failure.message.toLowerCase().contains('already') == true;

          if (isPendingError) {
            // User already has a pending request - add to pending list
            final newPendingIds = Set<String>.from(state.pendingRequestTeamIds)
              ..add(teamId);

            emit(
              state.copyWith(
                joiningTeamId: null,
                pendingRequestTeamIds: newPendingIds,
                errorMessage: null, // Don't show error for this case
              ),
            );
          } else {
            emit(
              state.copyWith(
                joiningTeamId: null,
                errorMessage: failure.message,
              ),
            );
          }
        }
      },
      (success) {
        if (!isClosed) {
          final newPendingIds = Set<String>.from(state.pendingRequestTeamIds)
            ..add(teamId);

          emit(
            state.copyWith(
              joiningTeamId: null,
              pendingRequestTeamIds: newPendingIds,
            ),
          );
        }
      },
    );
  }

  bool hasPendingRequest(String teamId) {
    return state.pendingRequestTeamIds.contains(teamId);
  }
}
