import 'package:equatable/equatable.dart';

/// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when app needs to check current auth status
class AuthStatusCheckRequested extends AuthEvent {}

/// Triggered when user attempts to sign in
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

/// Triggered when user attempts to sign up
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Triggered when user requests to sign out
class AuthSignOutRequested extends AuthEvent {}

/// Triggered when user requests password reset email
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object> get props => [email];
}

/// Triggered when user updates their profile
class AuthProfileUpdateRequested extends AuthEvent {
  final String? displayName;
  final String? photoURL;

  const AuthProfileUpdateRequested({
    this.displayName,
    this.photoURL,
  });

  @override
  List<Object?> get props => [displayName, photoURL];
}

/// Triggered when user requests account deletion
class AuthAccountDeletionRequested extends AuthEvent {}

