part of 'user_cubit.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserEntity user;

  const UserLoaded(this.user);

  @override
  List<Object> get props => [user];
}

class UserLoggedOut extends UserState {}

class UserLogoutError extends UserState {
  final String message;

  const UserLogoutError(this.message);

  @override
  List<Object> get props => [message];
}

class UserError extends UserState {
  final String message;
  final UserEntity? lastUser;

  const UserError(this.message, {this.lastUser});

  @override
  List<Object> get props => lastUser != null ? [message, lastUser!] : [message];
}
