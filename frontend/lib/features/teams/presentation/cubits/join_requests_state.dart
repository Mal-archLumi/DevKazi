part of 'join_requests_cubit.dart';

enum JoinRequestsStatus { initial, loading, loaded, error }

class JoinRequestsState {
  final JoinRequestsStatus status;
  final List<JoinRequestEntity> requests;
  final String? teamId;
  final String? processingRequestId;
  final String? errorMessage;
  final String? successMessage;

  const JoinRequestsState({
    required this.status,
    required this.requests,
    this.teamId,
    this.processingRequestId,
    this.errorMessage,
    this.successMessage,
  });

  factory JoinRequestsState.initial() {
    return const JoinRequestsState(
      status: JoinRequestsStatus.initial,
      requests: [],
    );
  }

  int get pendingCount => requests.where((r) => r.status == 'pending').length;

  JoinRequestsState copyWith({
    JoinRequestsStatus? status,
    List<JoinRequestEntity>? requests,
    String? teamId,
    String? processingRequestId,
    String? errorMessage,
    String? successMessage,
  }) {
    return JoinRequestsState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      teamId: teamId ?? this.teamId,
      processingRequestId: processingRequestId,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
