import 'package:dartz/dartz.dart';
import 'package:qr_menu_finder/core/error/failures.dart';

abstract class AnalyticsRepository {
  Future<Either<Failure, void>> initialize();
  Future<Either<Failure, void>> logEvent(String name, Map<String, dynamic>? parameters);
  Future<Either<Failure, void>> setUserProperty(String name, String value);
  Future<Either<Failure, void>> setUserId(String? id);
}
