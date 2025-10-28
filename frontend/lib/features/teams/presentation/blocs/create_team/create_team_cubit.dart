// presentation/blocs/create_team/create_team_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/teams/domain/use_cases/create_team_usecase.dart';
import 'create_team_state.dart';

class CreateTeamCubit extends Cubit<CreateTeamState> {
  final CreateTeamUseCase createTeamUseCase;

  CreateTeamCubit({required this.createTeamUseCase})
    : super(const CreateTeamState());

  void updateTeamName(String name) {
    emit(state.copyWith(name: name, nameError: _validateName(name)));
  }

  void updateDescription(String description) {
    emit(state.copyWith(description: description));
  }

  String? _validateName(String name) {
    if (name.isEmpty) {
      return 'Team name is required';
    }
    if (name.length < 2) {
      return 'Team name must be at least 2 characters';
    }
    if (name.length > 50) {
      return 'Team name cannot exceed 50 characters';
    }
    return null;
  }

  Future<void> createTeam() async {
    if (state.nameError != null || state.name.isEmpty) {
      emit(
        state.copyWith(
          nameError: _validateName(state.name),
          status: CreateTeamStatus.error,
          errorMessage: 'Please fix the errors above',
        ),
      );
      return;
    }

    emit(state.copyWith(status: CreateTeamStatus.loading));

    final result = await createTeamUseCase(
      state.name,
      description: state.description.isEmpty ? null : state.description,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CreateTeamStatus.error,
          errorMessage: _mapFailureToMessage(failure),
        ),
      ),
      (_) => emit(state.copyWith(status: CreateTeamStatus.success)),
    );
  }

  void reset() {
    emit(const CreateTeamState());
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Failed to create team. Please try again.';
      case CacheFailure:
        return 'No internet connection. Please check your connection.';
      default:
        return 'An unexpected error occurred';
    }
  }
}
