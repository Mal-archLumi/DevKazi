// core/errors/exceptions.dart
abstract class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.stackTrace]);

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred']);
}

class DataParsingException extends AppException {
  const DataParsingException([super.message = 'Data parsing failed']);
}

class SocketNotConnectedException extends AppException {
  const SocketNotConnectedException([super.message = 'Socket not connected']);
}

class AuthenticationException extends AppException {
  const AuthenticationException([super.message = 'Authentication failed']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache error occurred']);
}
