// features/teams/presentation/cubits/join_requests_cubit.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/teams/domain/entities/join_request_entity.dart';
import 'package:frontend/features/teams/domain/repositories/team_repository.dart';

part 'join_requests_state.dart';

class JoinRequestsCubit extends Cubit<JoinRequestsState> {
  final TeamRepository teamRepository;

  JoinRequestsCubit({required this.teamRepository})
    : super(JoinRequestsState.initial());

  Future<void> loadJoinRequests(String teamId) async {
    if (isClosed) return;

    debugPrint('🟡 JoinRequestsCubit: Loading join requests for team: $teamId');

    emit(state.copyWith(status: JoinRequestsStatus.loading, teamId: teamId));

    try {
      final result = await teamRepository.getTeamJoinRequests(teamId);

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
    } catch (e) {
      debugPrint('🔴 JoinRequestsCubit: Exception loading requests: $e');
      if (!isClosed) {
        emit(
          state.copyWith(
            status: JoinRequestsStatus.error,
            errorMessage: 'Failed to load join requests: $e',
          ),
        );
      }
    }
  }

  Future<void> approveRequest(String requestId) async {
    if (isClosed) return;

    debugPrint('🟡 JoinRequestsCubit: Approving request: $requestId');

    // ✅ Use unique ID for approve
    emit(state.copyWith(processingRequestId: 'approve_$requestId'));

    try {
      final result = await teamRepository.approveOrRejectJoinRequest(
        requestId: requestId,
        action: 'approve',
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
                errorMessage: 'Failed to approve: ${failure.message}',
              ),
            );
          }
        },
        (_) {
          debugPrint('🟢 JoinRequestsCubit: Request approved successfully');
          if (!isClosed) {
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
    } catch (e, stackTrace) {
      debugPrint('🔴 JoinRequestsCubit: Exception approving request: $e');
      debugPrint('🔴 Stack trace: $stackTrace');
      if (!isClosed) {
        emit(
          state.copyWith(
            processingRequestId: null,
            errorMessage: 'Failed to approve request: $e',
          ),
        );
      }
    }
  }

  Future<void> rejectRequest(String requestId) async {
    if (isClosed) return;

    debugPrint('🟡 JoinRequestsCubit: Rejecting request: $requestId');

    // ✅ Use unique ID for reject
    emit(state.copyWith(processingRequestId: 'reject_$requestId'));

    try {
      final result = await teamRepository.approveOrRejectJoinRequest(
        requestId: requestId,
        action: 'reject',
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
    } catch (e) {
      debugPrint('🔴 JoinRequestsCubit: Exception rejecting request: $e');
      if (!isClosed) {
        emit(
          state.copyWith(
            processingRequestId: null,
            errorMessage: 'Failed to reject request: $e',
          ),
        );
      }
    }
  }

  void clearMessages() {
    if (!isClosed) {
      emit(state.copyWith(errorMessage: null, successMessage: null));
    }
  }
}
