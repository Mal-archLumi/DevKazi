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
    emit(state.copyWith(status: TeamsStatus.loading, isSearching: false));

    final result = await getUserTeamsUseCase();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TeamsStatus.error,
          errorMessage: _mapFailureToMessage(failure),
          isSearching: false,
        ),
      ),
      (teams) => emit(
        state.copyWith(
          status: TeamsStatus.loaded,
          teams: teams,
          filteredTeams: teams,
          isSearching: false,
        ),
      ),
    );
  }

  Future<void> searchTeams(String query) async {
    if (query.isEmpty) {
      emit(
        state.copyWith(
          filteredTeams: state.teams,
          isSearching: false,
          searchQuery: '',
        ),
      );
      return;
    }

    emit(state.copyWith(isSearching: true, searchQuery: query));

    final result = await searchTeamsUseCase(query);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TeamsStatus.error,
          errorMessage: _mapFailureToMessage(failure),
          isSearching: false,
        ),
      ),
      (teams) => emit(state.copyWith(filteredTeams: teams, isSearching: true)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Failed to load teams. Please try again.';
      case CacheFailure:
        return 'No internet connection. Please check your connection.';
      default:
        return 'An unexpected error occurred';
    }
  }
}
