import 'package:dartz/dartz.dart';
import '../error/error.dart';

/// Helper class for common repository operations
/// Reduces code duplication across repository implementations
class RepositoryHelper {
  static Future<Either<Failure, T>> execute<T>(
    Future<dynamic> Function() operation, [
    T Function(dynamic)? transform,
  ]) async {
    try {
      final result = await operation();
      final transformedResult = transform != null
          ? transform(result)
          : result as T;
      return Right(transformedResult);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(GeneralFailure('Unexpected error: ${e.toString()}'));
    }
  }

  static Future<Either<Failure, List<T>>> executeList<T>(
    Future<List<dynamic>> Function() operation,
    T Function(dynamic) transform,
  ) async {
    try {
      final results = await operation();
      final transformedResults = results.map(transform).toList();
      return Right(transformedResults);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(GeneralFailure('Unexpected error: ${e.toString()}'));
    }
  }

  static Future<Either<Failure, void>> executeVoid(
    Future<void> Function() operation,
  ) async {
    try {
      await operation();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(GeneralFailure('Unexpected error: ${e.toString()}'));
    }
  }

  /// Yeni eklenen: void işlemleri Unit ile wrap eder
  static Future<Either<Failure, Unit>> executeUnit(
    Future<void> Function() operation,
  ) async {
    try {
      await operation();
      return const Right(unit); // dartz'tan gelen unit
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(GeneralFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
