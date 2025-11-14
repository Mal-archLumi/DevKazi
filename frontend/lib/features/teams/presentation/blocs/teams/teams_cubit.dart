// presentation/blocs/teams/teams_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/teams/domain/entities/team_entity.dart';
import 'package:frontend/features/teams/domain/use_cases/get_user_teams_usecase.dart';
import 'package:frontend/features/teams/domain/use_cases/search_teams_usecase.dart';
import 'teams_state.dart';

class TeamsCubit extends Cubit<TeamsState> {
  final GetUserTeamsUseCase getUserTeamsUseCase;
  final SearchTeamsUseCase searchTeamsUseCase;

  TeamsCubit({
    required this.getUserTeamsUseCase,
    required this.searchTeamsUseCase,
  }) : super(const TeamsState());

  Future<void> loadUserTeams() async {
    emit(state.copyWith(status: TeamsStatus.loading, searchQuery: ''));

    final result = await getUserTeamsUseCase();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TeamsStatus.error,
          errorMessage: _mapFailureToMessage(failure),
        ),
      ),
      (teams) => emit(
        state.copyWith(
          status: TeamsStatus.loaded,
          teams: teams,
          filteredTeams: teams,
        ),
      ),
    );
  }

  Future<void> searchTeams(String query) async {
    print('🟡 TeamsCubit.searchTeams: Called with query: "$query"');

    if (query.isEmpty) {
      print('🟢 TeamsCubit.searchTeams: Query empty, showing all teams');
      emit(state.copyWith(filteredTeams: state.teams, searchQuery: ''));
      return;
    }

    print('🟡 TeamsCubit.searchTeams: Searching for: "$query"');
    emit(state.copyWith(searchQuery: query, status: TeamsStatus.loading));

    final result = await searchTeamsUseCase(query);

    result.fold(
      (failure) {
        print(
          '🔴 TeamsCubit.searchTeams: Search failed - ${_mapFailureToMessage(failure)}',
        );
        emit(
          state.copyWith(
            status: TeamsStatus.error,
            errorMessage: _mapFailureToMessage(failure),
          ),
        );
      },
      (teams) {
        print(
          '🟢 TeamsCubit.searchTeams: Search successful, found ${teams.length} teams',
        );
        emit(state.copyWith(status: TeamsStatus.loaded, filteredTeams: teams));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Failed to load teams. Please try again.';
    } else if (failure is NetworkFailure) {
      return 'No internet connection. Please check your connection.';
    } else if (failure is CacheFailure) {
      return 'Storage error occurred. Please try again.';
    } else {
      return 'An unexpected error occurred';
    }
  }
}
