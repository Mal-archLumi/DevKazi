// core/errors/failures.dart
import 'exceptions.dart'; // Add this import

abstract class Failure {
  final String message;

  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure([String message = 'Server error occurred']) : super(message);

  factory ServerFailure.fromException(ServerException exception) {
    return ServerFailure(exception.message);
  }
}

class CacheFailure extends Failure {
  CacheFailure([String message = 'Cache error occurred']) : super(message);

  factory CacheFailure.fromException(CacheException exception) {
    return CacheFailure(exception.message);
  }
}

class NetworkFailure extends Failure {
  NetworkFailure([String message = 'Network error occurred']) : super(message);
}
