// lib/features/teams/presentation/blocs/team_details/team_details_cubit.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/features/teams/domain/entities/team_entity.dart';
import 'package:frontend/features/teams/domain/use_cases/get_team_by_id_usecase.dart';
import 'team_details_state.dart';
import 'package:frontend/core/events/user_status_events.dart';

class TeamDetailsCubit extends Cubit<TeamDetailsState> {
  final GetTeamByIdUseCase getTeamByIdUseCase;
  final StreamController<UserStatusEvent> userStatusController;
  StreamSubscription? _userStatusSubscription;

  TeamDetailsCubit({
    required this.getTeamByIdUseCase,
    required this.userStatusController,
  }) : super(const TeamDetailsState()) {
    print('🟢 TeamDetailsCubit: Constructor called, setting up listener');

    // Listen for user status updates
    _userStatusSubscription = userStatusController.stream.listen(
      (event) {
        print(
          '🟡 TeamDetailsCubit: Received UserStatusEvent - User: ${event.userId}, Online: ${event.isOnline}, Team: ${event.teamId}',
        );

        if (event is UserStatusEvent) {
          updateMemberOnlineStatus(event.userId, event.isOnline);
        } else {
          print(
            '🔴 TeamDetailsCubit: Received unknown event type: ${event.runtimeType}',
          );
        }
      },
      onError: (error) {
        print('🔴 TeamDetailsCubit: Error in userStatus stream: $error');
      },
    );
  }

  Future<void> loadTeamWithMembers(String teamId) async {
    print('🟡 TeamDetailsCubit: Loading team with members: $teamId');
    emit(state.copyWith(status: TeamDetailsStatus.loading));

    final result = await getTeamByIdUseCase(teamId);

    result.fold(
      (failure) {
        print(
          '🔴 TeamDetailsCubit: Failed to load team: ${_mapFailureToMessage(failure)}',
        );
        emit(
          state.copyWith(
            status: TeamDetailsStatus.error,
            errorMessage: _mapFailureToMessage(failure),
          ),
        );
      },
      (team) {
        print('🟢 TeamDetailsCubit: Successfully loaded team: ${team.name}');
        print('🟢 TeamDetailsCubit: Team has ${team.members.length} members');

        // Log initial online status of all members
        for (var member in team.members) {
          print(
            '🟡 TeamDetailsCubit: Member ${member.name} - Online: ${member.isOnline}',
          );
        }

        emit(state.copyWith(status: TeamDetailsStatus.loaded, team: team));
      },
    );
  }

  void setTeam(TeamEntity team) {
    print('🟡 TeamDetailsCubit: Setting team directly: ${team.name}');
    emit(state.copyWith(status: TeamDetailsStatus.loaded, team: team));
  }

  void updateMemberOnlineStatus(String userId, bool isOnline) {
    final currentTeam = state.team;
    if (currentTeam == null) {
      print('🔴 TeamDetailsCubit: Cannot update status - no current team');
      return;
    }

    print(
      '🟡 TeamDetailsCubit: Updating user $userId to ${isOnline ? 'online' : 'offline'}',
    );
    print(
      '🟡 TeamDetailsCubit: Current team has ${currentTeam.members.length} members',
    );

    var foundMember = false;
    final updatedMembers = currentTeam.members.map((member) {
      if (member.id == userId) {
        foundMember = true;
        print(
          '🟢 TeamDetailsCubit: Found user ${member.name}, updating online status to $isOnline',
        );
        return TeamMember(
          id: member.id,
          name: member.name,
          email: member.email,
          role: member.role,
          joinedAt: member.joinedAt,
          isOnline: isOnline,
        );
      }
      return member;
    }).toList();

    if (!foundMember) {
      print('🔴 TeamDetailsCubit: User $userId not found in team members');
      return;
    }

    final updatedTeam = currentTeam.copyWith(members: updatedMembers);
    emit(state.copyWith(team: updatedTeam));
    print('🟢 TeamDetailsCubit: Team updated with new online status');

    // Log final status of all members
    for (var member in updatedTeam.members) {
      print(
        '🟢 TeamDetailsCubit: Final status - ${member.name}: ${member.isOnline ? 'Online' : 'Offline'}',
      );
    }
  }

  String _mapFailureToMessage(Failure failure) {
    return 'Failed to load team details';
  }

  @override
  Future<void> close() {
    print('🟡 TeamDetailsCubit: Closing cubit, canceling subscriptions');
    _userStatusSubscription?.cancel();
    return super.close();
  }
}
