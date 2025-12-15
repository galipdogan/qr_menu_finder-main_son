import 'error_messages.dart';

/// Base exception class for clean architecture
///
/// Exceptions represent data-layer errors (network, cache, parsing, etc.).
/// They are thrown by data sources and caught by repositories to be converted to Failures.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const AppException(this.message, {this.code, this.stackTrace});

  /// Get user-friendly error message
  String get userMessage => ErrorMessages.getErrorMessage(message);

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Server-related exceptions (5xx errors, API failures)
class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.stackTrace});

  @override
  String get userMessage {
    // Check for specific server error types
    if (message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection')) {
      return ErrorMessages.noInternet;
    }
    if (message.toLowerCase().contains('timeout')) {
      return ErrorMessages.timeout;
    }
    return ErrorMessages.serverError;
  }
}

/// Cache-related exceptions (local storage failures)
class CacheException extends AppException {
  const CacheException(super.message, {super.code});

  @override
  String get userMessage => ErrorMessages.operationFailed;
}

/// Network-related exceptions (connection issues)
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});

  @override
  String get userMessage => ErrorMessages.noInternet;
}

/// Authentication and authorization exceptions
class AuthException extends AppException {
  const AuthException(super.message, {super.code});

  @override
  String get userMessage {
    // Try Firebase auth error code mapping first
    if (code != null) {
      return ErrorMessages.getFirebaseAuthErrorMessage(code!);
    }
    return ErrorMessages.notAuthenticated;
  }
}

/// Authentication required exception (user not logged in)
/// TR: Kimlik doğrulama gerekli exception (kullanıcı giriş yapmamış)
class AuthenticationException extends AppException {
  const AuthenticationException(super.message, {super.code});

  @override
  String get userMessage => ErrorMessages.notAuthenticated;
}

/// Permission denied exception (user doesn't have required permissions)
/// TR: İzin reddedildi exception (kullanıcının gerekli izinleri yok)
class PermissionDeniedException extends AppException {
  const PermissionDeniedException(super.message, {super.code});

  @override
  String get userMessage => message; // Permission messages are usually specific
}

/// Validation exceptions (invalid data format)
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});

  @override
  String get userMessage => message; // Validation messages are usually user-friendly already
}

/// Permission-related exceptions
class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});

  @override
  String get userMessage => ErrorMessages.locationPermissionDenied;
}

/// Resource not found exceptions (404 errors)
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code});

  @override
  String get userMessage {
    if (message.contains('Restaurant') || message.contains('restoran')) {
      return ErrorMessages.restaurantNotFound;
    }
    if (message.contains('Menu') || message.contains('menü')) {
      return ErrorMessages.menuNotFound;
    }
    return ErrorMessages.unknownError;
  }
}

/// General/unknown exceptions
class GeneralException extends AppException {
  const GeneralException(super.message, {super.code});

  @override
  String get userMessage => ErrorMessages.unknownError;
}
