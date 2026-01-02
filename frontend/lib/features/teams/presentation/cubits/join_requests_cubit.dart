// features/teams/presentation/cubits/join_requests_cubit.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/teams/domain/entities/join_request_entity.dart';
import 'package:frontend/features/teams/domain/use_cases/get_team_join_requests_usecase.dart';
import 'package:frontend/features/teams/domain/use_cases/handle_join_request_usecase.dart';

part 'join_requests_state.dart';

class JoinRequestsCubit extends Cubit<JoinRequestsState> {
  final GetTeamJoinRequestsUseCase getTeamJoinRequests;
  final HandleJoinRequestUseCase handleJoinRequest;

  JoinRequestsCubit({
    required this.getTeamJoinRequests,
    required this.handleJoinRequest,
  }) : super(JoinRequestsState.initial());

  Future<void> loadJoinRequests(String teamId) async {
    if (isClosed) return;

    debugPrint('🟡 JoinRequestsCubit: Loading join requests for team: $teamId');

    emit(state.copyWith(status: JoinRequestsStatus.loading, teamId: teamId));

    final result = await getTeamJoinRequests(teamId);

    if (isClosed) return;

    result.fold(
      (failure) {
        debugPrint(
          '🔴 JoinRequestsCubit: Failed to load requests: ${failure.message}',
        );
        if (!isClosed) {
          emit(
            state.copyWith(
              status: JoinRequestsStatus.error,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (requests) {
        debugPrint(
          '🟢 JoinRequestsCubit: Loaded ${requests.length} join requests',
        );
        if (!isClosed) {
          emit(
            state.copyWith(
              status: JoinRequestsStatus.loaded,
              requests: requests,
            ),
          );
        }
      },
    );
  }

  Future<void> approveRequest(String requestId) async {
    if (isClosed) return;

    debugPrint('🟡 JoinRequestsCubit: Approving request: $requestId');

    emit(state.copyWith(processingRequestId: requestId));

    final result = await handleJoinRequest(
      HandleJoinRequestParams(requestId: requestId, action: 'approve'),
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        debugPrint(
          '🔴 JoinRequestsCubit: Failed to approve: ${failure.message}',
        );
        if (!isClosed) {
          emit(
            state.copyWith(
              processingRequestId: null,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (_) {
        debugPrint('🟢 JoinRequestsCubit: Request approved successfully');
        if (!isClosed) {
          // Remove the approved request from list
          final updatedRequests = state.requests
              .where((req) => req.id != requestId)
              .toList();
          emit(
            state.copyWith(
              processingRequestId: null,
              requests: updatedRequests,
              successMessage: 'Request approved successfully',
            ),
          );
        }
      },
    );
  }

  Future<void> rejectRequest(String requestId) async {
    if (isClosed) return;

    debugPrint('🟡 JoinRequestsCubit: Rejecting request: $requestId');

    emit(state.copyWith(processingRequestId: requestId));

    final result = await handleJoinRequest(
      HandleJoinRequestParams(requestId: requestId, action: 'reject'),
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        debugPrint(
          '🔴 JoinRequestsCubit: Failed to reject: ${failure.message}',
        );
        if (!isClosed) {
          emit(
            state.copyWith(
              processingRequestId: null,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (_) {
        debugPrint('🟢 JoinRequestsCubit: Request rejected successfully');
        if (!isClosed) {
          // Remove the rejected request from list
          final updatedRequests = state.requests
              .where((req) => req.id != requestId)
              .toList();
          emit(
            state.copyWith(
              processingRequestId: null,
              requests: updatedRequests,
              successMessage: 'Request rejected',
            ),
          );
        }
      },
    );
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }
}
