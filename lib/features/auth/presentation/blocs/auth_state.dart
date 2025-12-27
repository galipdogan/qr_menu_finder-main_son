import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any auth check
class AuthInitial extends AuthState {}

/// State when checking current auth status (e.g., app startup)
class AuthChecking extends AuthState {}

/// State when performing an auth action (sign in, sign up, etc.)
class AuthLoading extends AuthState {}

/// State when user is authenticated
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

/// State when user is unauthenticated
class AuthUnauthenticated extends AuthState {
  final String? reason; // optional logout reason

  const AuthUnauthenticated({this.reason});

  @override
  List<Object?> get props => [reason];
}

/// State when an error occurs
class AuthError extends AuthState {
  final String message;
  final DateTime timestamp;

  AuthError({required this.message, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  @override
  List<Object> get props => [message, timestamp];
}

/// State when an action completes successfully without changing auth status
/// 
/// Used for operations like password reset email sent, profile updated, etc.
class AuthActionSuccess extends AuthState {
  final String message;
  final DateTime timestamp;

  AuthActionSuccess({required this.message, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  @override
  List<Object> get props => [message, timestamp];
}

