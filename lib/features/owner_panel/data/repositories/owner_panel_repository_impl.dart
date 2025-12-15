import 'package:dartz/dartz.dart';
import '../../../../core/error/error.dart';
import '../../../../core/utils/repository_helper.dart';
import '../../domain/entities/owner_stats.dart';
import '../../domain/entities/owner_restaurant.dart';
import '../../domain/repositories/owner_panel_repository.dart';
import '../datasources/owner_panel_remote_data_source.dart';

/// Implementation of OwnerPanelRepository
class OwnerPanelRepositoryImpl implements OwnerPanelRepository {
  final OwnerPanelRemoteDataSource remoteDataSource;

  OwnerPanelRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, OwnerStats>> getOwnerStats(String ownerId) async {
    return RepositoryHelper.execute(
      () => remoteDataSource.getOwnerStats(ownerId),
      (stats) => stats as OwnerStats,
    );
  }

  @override
  Future<Either<Failure, List<OwnerRestaurant>>> getOwnerRestaurants(
    String ownerId,
  ) async {
    return RepositoryHelper.execute(
      () => remoteDataSource.getOwnerRestaurants(ownerId),
      (restaurants) => restaurants as List<OwnerRestaurant>,
    );
  }

  @override
  Future<Either<Failure, void>> requestOwnerUpgrade(String userId) async {
    return RepositoryHelper.executeVoid(
      () => remoteDataSource.requestOwnerUpgrade(userId),
    );
  }
}
