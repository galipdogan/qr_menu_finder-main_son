import 'package:dartz/dartz.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/analytics/domain/repositories/analytics_repository.dart';

class InitializeAnalytics implements UseCase<void, NoParams> {
  final AnalyticsRepository repository;

  InitializeAnalytics(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.initialize();
  }
}
