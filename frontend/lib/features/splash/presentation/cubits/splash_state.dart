part of 'splash_cubit.dart';

abstract class SplashState {
  const SplashState();
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashLoaded extends SplashState {}

class SplashError extends SplashState {
  final String message;

  const SplashError(this.message);
}
