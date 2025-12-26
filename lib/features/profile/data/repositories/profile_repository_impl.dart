import 'package:dartz/dartz.dart';
import '../../../../core/error/error.dart';
import '../../../../core/utils/repository_helper.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

/// Implementation of profile repository
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> getUserProfile(String uid) async {
    return RepositoryHelper.execute(
      () => remoteDataSource.getUserProfile(uid),
      (model) => model as User,
    );
  }

  @override
  Future<Either<Failure, void>> updateProfile(User profile) async {
    return RepositoryHelper.executeVoid(() {
      // Convert User to UserModel for data source
      final profileModel = profile as dynamic; // UserModel extends User
      return remoteDataSource.updateProfile(profileModel);
    });
  }

  @override
  Stream<Either<Failure, User>> streamUserProfile(String uid) {
    try {
      return remoteDataSource
          .streamUserProfile(uid)
          .map(
            (profileModel) =>
                Right<Failure, User>(profileModel),
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
