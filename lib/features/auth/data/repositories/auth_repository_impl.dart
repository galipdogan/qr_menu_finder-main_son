import 'package:dartz/dartz.dart';
import '../../../../core/error/error.dart';
import '../../../../core/utils/repository_helper.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';
import '../models/user_model.dart';
import '../../../../core/mapper/mapper.dart'; // Mappr import

/// Implementation of AuthRepository using remote + local data sources
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final Mappr mappr = Mappr(); // merkezi mapper

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    return RepositoryHelper.execute<User?>(
      () async {
        final cached = await localDataSource.getCachedUser();
        if (cached != null) return cached;

        final remote = await remoteDataSource.getCurrentUser();
        if (remote != null) {
          await localDataSource.cacheUser(remote);
        }
        return remote;
      },
      (userModel) =>
          userModel == null ? null : mappr.convert<UserModel, User>(userModel),
    );
  }

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return RepositoryHelper.execute<User>(() async {
      final user = await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await localDataSource.cacheUser(user);
      return user;
    }, (userModel) => mappr.convert<UserModel, User>(userModel));
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return RepositoryHelper.execute<User>(() async {
      final user = await remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      await localDataSource.cacheUser(user);
      return user;
    }, (userModel) => mappr.convert<UserModel, User>(userModel));
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    return RepositoryHelper.executeUnit(() async {
      await remoteDataSource.signOut();
      await localDataSource.clearCache();
    });
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail({
    required String email,
  }) async {
    return RepositoryHelper.executeUnit(
      () => remoteDataSource.sendPasswordResetEmail(email: email),
    );
  }

  @override
  Future<Either<Failure, User>> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    return RepositoryHelper.execute<User>(() async {
      final user = await remoteDataSource.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      await localDataSource.cacheUser(user);
      return user;
    }, (userModel) => mappr.convert<UserModel, User>(userModel));
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount() async {
    return RepositoryHelper.executeUnit(() async {
      await remoteDataSource.deleteAccount();
      await localDataSource.clearCache();
    });
  }

  @override
  Stream<User?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((userModel) {
      if (userModel != null) {
        localDataSource.cacheUser(userModel);
      }
      return userModel == null
          ? null
          : mappr.convert<UserModel, User>(userModel);
    });
  }
}
