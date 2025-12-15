import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/owner_stats.dart';
import '../repositories/owner_panel_repository.dart';

/// Use case for getting owner statistics
class GetOwnerStats implements UseCase<OwnerStats, String> {
  final OwnerPanelRepository repository;

  GetOwnerStats(this.repository);

  @override
  Future<Either<Failure, OwnerStats>> call(String params) async {
    return await repository.getOwnerStats(params);
  }
}
