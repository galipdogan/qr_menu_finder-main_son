import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/compared_price.dart';
import '../repositories/price_comparison_repository.dart';

/// UseCase for getting compared prices across different restaurants
class GetComparedPrices
    implements UseCase<List<ComparedPrice>, GetComparedPricesParams> {
  final PriceComparisonRepository repository;

  GetComparedPrices(this.repository);

  @override
  Future<Either<Failure, List<ComparedPrice>>> call(
    GetComparedPricesParams params,
  ) async {
    return await repository.getComparedPrices(
      params.itemName,
      params.currentRestaurantId,
    );
  }
}

/// Parameters for GetComparedPrices UseCase
class GetComparedPricesParams extends Equatable {
  final String itemName;
  final String currentRestaurantId;

  const GetComparedPricesParams({
    required this.itemName,
    required this.currentRestaurantId,
  });

  @override
  List<Object?> get props => [itemName, currentRestaurantId];
}
