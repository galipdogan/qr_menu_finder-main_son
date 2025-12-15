import 'exceptions.dart';
import 'failures.dart';
import 'error_messages.dart';

/// Centralized error handling utility for Clean Architecture
///
/// This class provides methods to convert exceptions to failures and handle errors consistently.
class ErrorHandler {
  /// Convert an exception to a failure
  ///
  /// This is typically used in repositories to convert data layer exceptions
  /// to domain layer failures.
  static Failure exceptionToFailure(dynamic exception) {
    if (exception is ServerException) {
      return ServerFailure(
        exception.message,
        code: exception.code,
        originalError: exception,
      );
    } else if (exception is NetworkException) {
      return NetworkFailure(
        exception.message,
        code: exception.code,
        originalError: exception,
      );
    } else if (exception is CacheException) {
      return CacheFailure(
        exception.message,
        code: exception.code,
        originalError: exception,
      );
    } else if (exception is AuthException) {
      return AuthFailure(
        exception.message,
        code: exception.code,
        originalError: exception,
      );
    } else if (exception is ValidationException) {
      return ValidationFailure(
        exception.message,
        code: exception.code,
        originalError: exception,
      );
    } else if (exception is PermissionException) {
      return PermissionFailure(
        exception.message,
        code: exception.code,
        originalError: exception,
      );
    } else if (exception is NotFoundException) {
      return NotFoundFailure(
        exception.message,
        code: exception.code,
        originalError: exception,
      );
    } else {
      return GeneralFailure(
        exception.toString(),
        originalError: exception,
      );
    }
  }

  /// Get user-friendly message from any error
  ///
  /// This method can handle both exceptions and failures.
  static String getUserMessage(dynamic error) {
    if (error is AppException) {
      return error.userMessage;
    } else if (error is Failure) {
      return error.userMessage;
    } else if (error is String) {
      return ErrorMessages.getErrorMessage(error);
    } else {
      return ErrorMessages.unknownError;
    }
  }

  /// Get error icon from any error
  static String getErrorIcon(dynamic error) {
    final message = getUserMessage(error);
    return ErrorMessages.getErrorIcon(message);
  }

  /// Check if error is network-related
  static bool isNetworkError(dynamic error) {
    if (error is NetworkException || error is NetworkFailure) {
      return true;
    }
    final message = error.toString().toLowerCase();
    return message.contains('network') ||
        message.contains('connection') ||
        message.contains('internet');
  }

  /// Check if error is authentication-related
  static bool isAuthError(dynamic error) {
    return error is AuthException || error is AuthFailure;
  }

  /// Check if error is not found
  static bool isNotFoundError(dynamic error) {
    return error is NotFoundException || error is NotFoundFailure;
  }

  /// Check if error requires user action (login, permission, etc.)
  static bool requiresUserAction(dynamic error) {
    return isAuthError(error) ||
        error is PermissionException ||
        error is PermissionFailure;
  }
}
