import 'package:dartz/dartz.dart';
import '../../../../core/error/error.dart';
import '../../../../core/utils/repository_helper.dart';
import '../../domain/entities/compared_price.dart';
import '../../domain/repositories/price_comparison_repository.dart';
import '../datasources/price_comparison_remote_data_source.dart';

/// Implementation of PriceComparisonRepository
class PriceComparisonRepositoryImpl implements PriceComparisonRepository {
  final PriceComparisonRemoteDataSource remoteDataSource;

  PriceComparisonRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ComparedPrice>>> getComparedPrices(
    String itemName,
    String currentRestaurantId,
  ) async {
    return RepositoryHelper.executeList(
      () => remoteDataSource.getComparedPrices(itemName, currentRestaurantId),
      (model) => model.toEntity(),
    );
  }
}
