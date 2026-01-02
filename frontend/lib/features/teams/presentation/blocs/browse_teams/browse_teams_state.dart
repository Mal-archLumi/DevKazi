// features/teams/presentation/blocs/browse_teams/browse_teams_state.dart
part of 'browse_teams_cubit.dart';

enum BrowseTeamsStatus { initial, loading, loaded, error }

class BrowseTeamsState {
  final BrowseTeamsStatus status;
  final List<TeamEntity> teams;
  final List<TeamEntity> allTeams;
  final List<TeamEntity> filteredTeams;
  final Set<String> userTeamIds;
  final bool isSearching;
  final String searchQuery;
  final String? errorMessage;
  final String? joiningTeamId;
  final Set<String> pendingRequestTeamIds;

  const BrowseTeamsState({
    required this.status,
    required this.teams,
    required this.allTeams,
    required this.filteredTeams,
    required this.userTeamIds,
    required this.isSearching,
    required this.searchQuery,
    this.errorMessage,
    this.joiningTeamId,
    required this.pendingRequestTeamIds,
  });

  factory BrowseTeamsState.initial() {
    return const BrowseTeamsState(
      status: BrowseTeamsStatus.initial,
      teams: [],
      allTeams: [],
      filteredTeams: [],
      userTeamIds: {},
      isSearching: false,
      searchQuery: '',
      errorMessage: null,
      joiningTeamId: null,
      pendingRequestTeamIds: {},
    );
  }

  BrowseTeamsState copyWith({
    BrowseTeamsStatus? status,
    List<TeamEntity>? teams,
    List<TeamEntity>? allTeams,
    List<TeamEntity>? filteredTeams,
    Set<String>? userTeamIds,
    bool? isSearching,
    String? searchQuery,
    String? errorMessage,
    String? joiningTeamId,
    Set<String>? pendingRequestTeamIds,
  }) {
    return BrowseTeamsState(
      status: status ?? this.status,
      teams: teams ?? this.teams,
      allTeams: allTeams ?? this.allTeams,
      filteredTeams: filteredTeams ?? this.filteredTeams,
      userTeamIds: userTeamIds ?? this.userTeamIds,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      joiningTeamId: joiningTeamId,
      pendingRequestTeamIds:
          pendingRequestTeamIds ?? this.pendingRequestTeamIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BrowseTeamsState &&
        other.status == status &&
        listEquals(other.teams, teams) &&
        listEquals(other.allTeams, allTeams) &&
        listEquals(other.filteredTeams, filteredTeams) &&
        setEquals(other.userTeamIds, userTeamIds) &&
        other.isSearching == isSearching &&
        other.searchQuery == searchQuery &&
        other.errorMessage == errorMessage &&
        other.joiningTeamId == joiningTeamId &&
        setEquals(other.pendingRequestTeamIds, pendingRequestTeamIds);
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      teams,
      allTeams,
      filteredTeams,
      userTeamIds,
      isSearching,
      searchQuery,
      errorMessage,
      joiningTeamId,
      pendingRequestTeamIds,
    );
  }
}
