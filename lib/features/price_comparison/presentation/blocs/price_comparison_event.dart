part of 'price_comparison_bloc.dart';

/// Base class for all PriceComparison events
abstract class PriceComparisonEvent extends Equatable {
  const PriceComparisonEvent();

  @override
  List<Object> get props => [];
}

/// Event to request price comparison for a menu item
class PriceComparisonRequested extends PriceComparisonEvent {
  final String itemName;
  final String currentRestaurantId;
  final String currentProductId;

  const PriceComparisonRequested({
    required this.itemName,
    required this.currentRestaurantId,
    required this.currentProductId,
  });

  @override
  List<Object> get props => [itemName, currentRestaurantId, currentProductId];
}
