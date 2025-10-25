// presentation/blocs/teams/teams_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:frontend/core/errors/failures.dart';
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
    emit(state.copyWith(status: TeamsStatus.loading));

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
          status: TeamsStatus.success,
          teams: teams,
          filteredTeams: teams,
        ),
      ),
    );
  }

  void searchTeams(String query) {
    if (query.isEmpty) {
      emit(state.copyWith(searchQuery: query, filteredTeams: state.teams));
      return;
    }

    emit(
      state.copyWith(
        searchQuery: query,
        filteredTeams: state.teams
            .where(
              (team) => team.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList(),
      ),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred';
      case CacheFailure:
        return 'No internet connection. Showing cached data';
      default:
        return 'An unexpected error occurred';
    }
  }
}
