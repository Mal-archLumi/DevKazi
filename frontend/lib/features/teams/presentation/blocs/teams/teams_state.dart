// presentation/blocs/teams/teams_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/team_entity.dart';

enum TeamsStatus { initial, loading, success, error, loaded }

class TeamsState extends Equatable {
  final TeamsStatus status;
  final List<TeamEntity> teams;
  final List<TeamEntity> filteredTeams;
  final String searchQuery;
  final String errorMessage;

  const TeamsState({
    this.status = TeamsStatus.initial,
    this.teams = const [],
    this.filteredTeams = const [],
    this.searchQuery = '',
    this.errorMessage = '',
  });

  bool get isSearching => searchQuery.isNotEmpty;
  bool get isEmpty => teams.isEmpty && status == TeamsStatus.success;

  TeamsState copyWith({
    TeamsStatus? status,
    List<TeamEntity>? teams,
    List<TeamEntity>? filteredTeams,
    String? searchQuery,
    String? errorMessage,
    required bool isSearching,
  }) {
    return TeamsState(
      status: status ?? this.status,
      teams: teams ?? this.teams,
      filteredTeams: filteredTeams ?? this.filteredTeams,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [
    status,
    teams,
    filteredTeams,
    searchQuery,
    errorMessage,
  ];
}
