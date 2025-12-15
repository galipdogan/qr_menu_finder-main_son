part of 'price_comparison_bloc.dart';

/// Base class for all PriceComparison states
abstract class PriceComparisonState extends Equatable {
  const PriceComparisonState();

  @override
  List<Object> get props => [];
}

/// Initial state
class PriceComparisonInitial extends PriceComparisonState {}

/// Loading state while fetching prices
class PriceComparisonLoading extends PriceComparisonState {}

/// Success state with loaded prices
class PriceComparisonLoaded extends PriceComparisonState {
  final List<ComparedPrice> prices;

  const PriceComparisonLoaded({required this.prices});

  @override
  List<Object> get props => [prices];
}

/// Error state with error message
class PriceComparisonError extends PriceComparisonState {
  final String message;

  const PriceComparisonError(this.message);

  @override
  List<Object> get props => [message];
}
