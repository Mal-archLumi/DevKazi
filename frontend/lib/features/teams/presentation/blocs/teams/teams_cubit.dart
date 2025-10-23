// presentation/blocs/teams/teams_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/teams/domain/use_cases/get_user_teams_usecase.dart';
import 'package:frontend/features/teams/domain/use_cases/search_teams_usecase.dart';
import '../../../domain/usecases/get_user_teams_usecase.dart';
import '../../../domain/usecases/search_teams_usecase.dart';
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
          errorMessage: _mapFailureToMessage(failure as Failure),
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

    // Optional: Implement real-time search with backend
    // _performBackendSearch(query);
  }

  Future<void> _performBackendSearch(String query) async {
    final result = await searchTeamsUseCase(query);

    result.fold(
      (failure) => null, // Don't show error for search failures
      (teams) => emit(state.copyWith(filteredTeams: teams)),
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
