import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart'; // Import for FirebaseException
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:qr_menu_finder/features/analytics/data/datasources/analytics_remote_data_source.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      await remoteDataSource.initialize();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase Analytics initialization error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logEvent(String name, Map<String, dynamic>? parameters) async {
    try {
      await remoteDataSource.logEvent(name, parameters);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase Analytics log event error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setUserProperty(String name, String value) async {
    try {
      await remoteDataSource.setUserProperty(name, value);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase Analytics set user property error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setUserId(String? id) async {
    try {
      await remoteDataSource.setUserId(id);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase Analytics set user ID error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
