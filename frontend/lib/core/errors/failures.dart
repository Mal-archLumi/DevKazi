// lib/core/errors/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.stackTrace]);

  @override
  List<Object?> get props => [message, stackTrace];

  @override
  String toString() => 'Failure: $message';
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class DataParsingFailure extends Failure {
  const DataParsingFailure([super.message = 'Data parsing failed']);
}

class SocketFailure extends Failure {
  const SocketFailure([super.message = 'Socket connection failed']);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message = 'Authentication failed']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message);

  @override
  String toString() => 'ConnectionFailure: $message';
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
