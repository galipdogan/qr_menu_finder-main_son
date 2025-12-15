import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/owner_stats.dart';
import '../entities/owner_restaurant.dart';

/// Repository interface for Owner Panel feature
abstract class OwnerPanelRepository {
  /// Get owner statistics
  Future<Either<Failure, OwnerStats>> getOwnerStats(String ownerId);

  /// Get owner's restaurants with details
  Future<Either<Failure, List<OwnerRestaurant>>> getOwnerRestaurants(String ownerId);

  /// Request owner account upgrade
  Future<Either<Failure, void>> requestOwnerUpgrade(String userId);
}
