import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/compared_price.dart';

/// Repository interface for price comparison operations
abstract class PriceComparisonRepository {
  /// Get compared prices for a menu item across different restaurants
  ///
  /// [itemName] - Name of the menu item to compare
  /// [currentRestaurantId] - ID of the current restaurant to exclude from results
  Future<Either<Failure, List<ComparedPrice>>> getComparedPrices(
    String itemName,
    String currentRestaurantId,
  );
}
