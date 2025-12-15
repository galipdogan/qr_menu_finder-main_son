import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Abstract auth repository for clean architecture
abstract class AuthRepository {
  /// Get current user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Sign in with email and password
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign out
  Future<Either<Failure, Unit>> signOut();

  /// Send password reset email
  Future<Either<Failure, Unit>> sendPasswordResetEmail({required String email});

  /// Update user profile
  Future<Either<Failure, User>> updateUserProfile({
    String? displayName,
    String? photoURL,
  });

  /// Delete user account
  Future<Either<Failure, Unit>> deleteAccount();

  /// Stream of auth state changes
  Stream<User?> get authStateChanges;
}
