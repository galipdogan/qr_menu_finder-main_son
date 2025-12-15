import 'package:equatable/equatable.dart';

/// Entity representing a price comparison for a menu item across different restaurants
class ComparedPrice extends Equatable {
  final String restaurantId;
  final String restaurantName;
  final double price;
  final String currency;

  const ComparedPrice({
    required this.restaurantId,
    required this.restaurantName,
    required this.price,
    required this.currency,
  });

  @override
  List<Object?> get props => [restaurantId, restaurantName, price, currency];
}
