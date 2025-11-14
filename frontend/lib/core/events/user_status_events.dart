class UserStatusEvent {
  final String userId;
  final String teamId;
  final bool isOnline;

  UserStatusEvent({
    required this.userId,
    required this.teamId,
    required this.isOnline,
  });
}
