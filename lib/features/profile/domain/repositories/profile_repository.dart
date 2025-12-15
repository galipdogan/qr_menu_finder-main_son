import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';

/// Abstract repository for profile operations
abstract class ProfileRepository {
  /// Get user profile by ID
  Future<Either<Failure, UserProfile>> getUserProfile(String uid);

  /// Update user profile
  Future<Either<Failure, void>> updateProfile(UserProfile profile);

  /// Stream user profile changes
  Stream<Either<Failure, UserProfile>> streamUserProfile(String uid);

  /// Update user role (admin only)
  Future<Either<Failure, void>> updateUserRole({
    required String uid,
    required UserRole role,
  });
}
