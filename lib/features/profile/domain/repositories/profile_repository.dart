import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user.dart';

/// Abstract repository for profile operations
abstract class ProfileRepository {
  /// Get user profile by ID
  Future<Either<Failure, User>> getUserProfile(String uid);

  /// Update user profile
  Future<Either<Failure, void>> updateProfile(User profile);

  /// Stream user profile changes
  Stream<Either<Failure, User>> streamUserProfile(String uid);

  /// Update user role (admin only)
  Future<Either<Failure, void>> updateUserRole({
    required String uid,
    required UserRole role,
  });
}
