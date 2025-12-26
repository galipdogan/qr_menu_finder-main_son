import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/profile_repository.dart';

/// Use case for updating user profile
class UpdateProfile implements UseCase<void, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateProfileParams params) async {
    // Validate name is not empty
    if (params.profile.name.trim().isEmpty) {
      return Left(ValidationFailure('İsim boş olamaz'));
    }

    return await repository.updateProfile(params.profile);
  }
}

/// Parameters for updating profile
class UpdateProfileParams extends Equatable {
  final User profile;

  const UpdateProfileParams({required this.profile});

  @override
  List<Object> get props => [profile];
}
