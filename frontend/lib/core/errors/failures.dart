// core/errors/failures.dart
import 'exceptions.dart'; // Add this import

abstract class Failure {
  final String message;

  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure([super.message = 'Server error occurred']);

  factory ServerFailure.fromException(ServerException exception) {
    return ServerFailure(exception.message);
  }
}

class CacheFailure extends Failure {
  CacheFailure([super.message = 'Cache error occurred']);

  factory CacheFailure.fromException(CacheException exception) {
    return CacheFailure(exception.message);
  }
}

class NetworkFailure extends Failure {
  NetworkFailure([super.message = 'Network error occurred']);
}
