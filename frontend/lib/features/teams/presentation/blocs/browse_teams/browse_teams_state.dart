// features/teams/presentation/blocs/browse_teams/browse_teams_state.dart
part of 'browse_teams_cubit.dart';

enum BrowseTeamsStatus { initial, loading, loaded, error }

class BrowseTeamsState {
  final BrowseTeamsStatus status;
  final List<TeamEntity> teams;
  final List<TeamEntity> filteredTeams;
  final bool isSearching;
  final String? errorMessage;

  const BrowseTeamsState({
    required this.status,
    required this.teams,
    required this.filteredTeams,
    required this.isSearching,
    this.errorMessage,
  });

  factory BrowseTeamsState.initial() {
    return const BrowseTeamsState(
      status: BrowseTeamsStatus.initial,
      teams: [],
      filteredTeams: [],
      isSearching: false,
      errorMessage: null,
    );
  }

  BrowseTeamsState copyWith({
    BrowseTeamsStatus? status,
    List<TeamEntity>? teams,
    List<TeamEntity>? filteredTeams,
    bool? isSearching,
    String? errorMessage,
  }) {
    return BrowseTeamsState(
      status: status ?? this.status,
      teams: teams ?? this.teams,
      filteredTeams: filteredTeams ?? this.filteredTeams,
      isSearching: isSearching ?? this.isSearching,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BrowseTeamsState &&
        other.status == status &&
        listEquals(other.teams, teams) &&
        listEquals(other.filteredTeams, filteredTeams) &&
        other.isSearching == isSearching &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        teams.hashCode ^
        filteredTeams.hashCode ^
        isSearching.hashCode ^
        errorMessage.hashCode;
  }
}
