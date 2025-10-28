// presentation/blocs/create_team/create_team_state.dart
import 'package:equatable/equatable.dart';

enum CreateTeamStatus { initial, loading, success, error }

class CreateTeamState extends Equatable {
  final CreateTeamStatus status;
  final String name;
  final String description;
  final String? nameError;
  final String errorMessage;

  const CreateTeamState({
    this.status = CreateTeamStatus.initial,
    this.name = '',
    this.description = '',
    this.nameError,
    this.errorMessage = '',
  });

  bool get isValid => nameError == null && name.isNotEmpty;
  bool get isLoading => status == CreateTeamStatus.loading;

  CreateTeamState copyWith({
    CreateTeamStatus? status,
    String? name,
    String? description,
    String? nameError,
    String? errorMessage,
  }) {
    return CreateTeamState(
      status: status ?? this.status,
      name: name ?? this.name,
      description: description ?? this.description,
      nameError: nameError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    name,
    description,
    nameError,
    errorMessage,
  ];
}
