import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_email_password.dart';
import '../../domain/usecases/sign_up_with_email_password.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/send_password_reset_email.dart';
import '../../domain/usecases/update_user_profile.dart';
import '../../domain/usecases/delete_user_account.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/usecases/usecase.dart';

import 'auth_event.dart';
import 'auth_state.dart';

/// AuthBloc - Manages authentication state
/// 
/// Refactored to support all auth operations with proper separation of concerns
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUser getCurrentUser;
  final SignInWithEmailPassword signInWithEmailPassword;
  final SignUpWithEmailPassword signUpWithEmailPassword;
  final SignOut signOut;
  final SendPasswordResetEmail sendPasswordResetEmail;
  final UpdateUserProfile updateUserProfile;
  final DeleteUserAccount deleteUserAccount;

  AuthBloc({
    required this.getCurrentUser,
    required this.signInWithEmailPassword,
    required this.signUpWithEmailPassword,
    required this.signOut,
    required this.sendPasswordResetEmail,
    required this.updateUserProfile,
    required this.deleteUserAccount,
  }) : super(AuthInitial()) {
    on<AuthStatusCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
    on<AuthAccountDeletionRequested>(_onAccountDeletionRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthStatusCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.i('AuthBloc: Checking authentication status...');
    emit(AuthChecking());

    final result = await getCurrentUser();

    result.fold(
      (failure) {
        AppLogger.e('AuthBloc: Auth check failed', error: failure.message);
        emit(AuthError(message: failure.userMessage));
      },
      (user) {
        if (user != null) {
          AppLogger.i('AuthBloc: User authenticated - ${user.email}');
          emit(AuthAuthenticated(user: user));
        } else {
          AppLogger.i('AuthBloc: No user authenticated');
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _handleAuthAction(
      emit,
      () => signInWithEmailPassword(
        SignInParams(email: event.email, password: event.password),
      ),
      successLog: 'AuthBloc: Sign in successful - ${event.email}',
      failureLog: 'AuthBloc: Sign in failed for ${event.email}',
    );
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _handleAuthAction(
      emit,
      () => signUpWithEmailPassword(
        SignUpParams(
          email: event.email,
          password: event.password,
          displayName: event.displayName,
        ),
      ),
      successLog: 'AuthBloc: Sign up successful - ${event.email}',
      failureLog: 'AuthBloc: Sign up failed for ${event.email}',
    );
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.i('AuthBloc: Sign out requested');
    emit(AuthLoading());

    final result = await signOut();

    result.fold(
      (failure) {
        AppLogger.e('AuthBloc: Sign out failed', error: failure.message);
        emit(AuthError(message: failure.userMessage));
      },
      (_) {
        AppLogger.i('AuthBloc: Sign out successful');
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.i('AuthBloc: Password reset requested for ${event.email}');
    emit(AuthLoading());

    final result = await sendPasswordResetEmail(
      SendPasswordResetParams(email: event.email),
    );

    result.fold(
      (failure) {
        AppLogger.e('AuthBloc: Password reset failed', error: failure.message);
        emit(AuthError(message: failure.userMessage));
      },
      (_) {
        AppLogger.i('AuthBloc: Password reset email sent');
        emit(AuthActionSuccess(
          message: 'Şifre sıfırlama e-postası gönderildi',
        ));
      },
    );
  }

  Future<void> _onProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.i('AuthBloc: Profile update requested');
    emit(AuthLoading());

    final result = await updateUserProfile(
      UpdateUserProfileParams(
        displayName: event.displayName,
        photoURL: event.photoURL,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.e('AuthBloc: Profile update failed', error: failure.message);
        emit(AuthError(message: failure.userMessage));
      },
      (user) {
        AppLogger.i('AuthBloc: Profile updated successfully');
        emit(AuthAuthenticated(user: user));
      },
    );
  }

  Future<void> _onAccountDeletionRequested(
    AuthAccountDeletionRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.i('AuthBloc: Account deletion requested');
    emit(AuthLoading());

    final result = await deleteUserAccount(NoParams());

    result.fold(
      (failure) {
        AppLogger.e('AuthBloc: Account deletion failed', error: failure.message);
        emit(AuthError(message: failure.userMessage));
      },
      (_) {
        AppLogger.i('AuthBloc: Account deleted successfully');
        emit(const AuthUnauthenticated(reason: 'Hesap silindi'));
      },
    );
  }

  // Helper method for auth actions that return a User
  Future<void> _handleAuthAction(
    Emitter<AuthState> emit,
    Future<dynamic> Function() action, {
    required String successLog,
    required String failureLog,
  }) async {
    emit(AuthLoading());
    final result = await action();

    result.fold(
      (failure) {
        AppLogger.e(failureLog, error: failure.message);
        emit(AuthError(message: failure.userMessage));
      },
      (user) {
        AppLogger.i(successLog);
        emit(AuthAuthenticated(user: user));
      },
    );
  }
}
