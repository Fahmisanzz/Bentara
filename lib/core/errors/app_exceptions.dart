abstract class AppException implements Exception {
  final String message;
  final String? prefix;
  AppException([this.message = '', this.prefix]);

  @override
  String toString() => '${prefix != null ? "$prefix: " : ""}$message';
}

class NetworkException extends AppException {
  NetworkException([String message = 'Network connection failed']) : super(message, 'Network Error');
}

class AuthException extends AppException {
  AuthException([String message = 'Authentication failed']) : super(message, 'Auth Error');
}

class StorageException extends AppException {
  StorageException([String message = 'Local storage failed']) : super(message, 'Storage Error');
}

class AIException extends AppException {
  AIException([String message = 'AI service failed']) : super(message, 'AI Error');
}
