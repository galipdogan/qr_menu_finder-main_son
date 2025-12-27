import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// UseCase for updating user profile
/// 
/// Follows Clean Architecture - encapsulates business logic
class UpdateUserProfile implements UseCase<User, UpdateUserProfileParams> {
  final AuthRepository repository;

  UpdateUserProfile(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateUserProfileParams params) async {
    return await repository.updateUserProfile(
      displayName: params.displayName,
      photoURL: params.photoURL,
    );
  }
}

/// Parameters for updating user profile
class UpdateUserProfileParams {
  final String? displayName;
  final String? photoURL;

  const UpdateUserProfileParams({
    this.displayName,
    this.photoURL,
  });

  /// Validates that at least one field is provided
  bool get isValid => displayName != null || photoURL != null;
}
