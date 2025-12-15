import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

/// Use case for getting user profile
class GetUserProfile implements UseCase<UserProfile, GetUserProfileParams> {
  final ProfileRepository repository;

  GetUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(GetUserProfileParams params) async {
    return await repository.getUserProfile(params.uid);
  }
}

/// Parameters for getting user profile
class GetUserProfileParams extends Equatable {
  final String uid;

  const GetUserProfileParams({required this.uid});

  @override
  List<Object> get props => [uid];
}
