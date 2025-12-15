import 'package:equatable/equatable.dart';
import 'error_messages.dart';

/// Base failure class for clean architecture
///
/// Failures represent domain-level errors that occur during business logic execution.
/// They are returned as Left values in Eitherpatterns.
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic originalError;

  const Failure(this.message, {this.code, this.originalError});

  /// Get user-friendly error message
  String get userMessage => ErrorMessages.getErrorMessage(message);

  /// Get error icon for UI display
  String get icon => ErrorMessages.getErrorIcon(message);

  @override
  List<Object?> get props => [message, code, originalError];
}

/// Server-related failures (5xx errors, backend issues)
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.originalError});
}

/// Cache-related failures (local storage issues)
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code, super.originalError});
}

/// Network-related failures (connection issues, timeouts)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.originalError});
}

/// Authentication and authorization failures
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.originalError});

  @override
  String get userMessage {
    // Try Firebase auth error message first
    if (code != null &&
        ErrorMessages.getFirebaseAuthErrorMessage(code!).isNotEmpty) {
      return ErrorMessages.getFirebaseAuthErrorMessage(code!);
    }
    return ErrorMessages.getErrorMessage(message);
  }
}

/// Authentication required failure (user not logged in)
/// TR: Kimlik doğrulama gerekli failure (kullanıcı giriş yapmamış)
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, {super.code, super.originalError});

  @override
  String get userMessage => ErrorMessages.notAuthenticated;
}

/// Validation failures (invalid input, business rule violations)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.originalError});
}

/// Permission-related failures (location, camera, etc.)
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code, super.originalError});
}

/// Resource not found failures (404 errors)
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code, super.originalError});

  @override
  String get userMessage => ErrorMessages.restaurantNotFound;
}

/// General/unknown failures
class GeneralFailure extends Failure {
  const GeneralFailure(super.message, {super.code, super.originalError});
}
