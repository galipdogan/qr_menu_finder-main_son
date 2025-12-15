import 'package:dartz/dartz.dart';
import '../../../../core/error/error.dart';
import '../../../../core/utils/repository_helper.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/user_profile_model.dart';

/// Implementation of profile repository
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String uid) async {
    return RepositoryHelper.execute(
      () => remoteDataSource.getUserProfile(uid),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, void>> updateProfile(UserProfile profile) async {
    return RepositoryHelper.executeVoid(() {
      final profileModel = UserProfileModel.fromEntity(profile);
      return remoteDataSource.updateProfile(profileModel);
    });
  }

  @override
  Stream<Either<Failure, UserProfile>> streamUserProfile(String uid) {
    try {
      return remoteDataSource
          .streamUserProfile(uid)
          .map(
            (profileModel) =>
                Right<Failure, UserProfile>(profileModel.toEntity()),
          );
    } on ServerException catch (e) {
      return Stream.value(Left(ServerFailure(e.message, code: e.code)));
    } catch (e) {
      return Stream.value(
        Left(GeneralFailure('Unexpected error: ${e.toString()}')),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateUserRole({
    required String uid,
    required UserRole role,
  }) async {
    return RepositoryHelper.executeVoid(
      () => remoteDataSource.updateUserRole(uid: uid, role: role),
    );
  }
}
