import 'package:equatable/equatable.dart';
import '../../domain/entities/owner_stats.dart';
import '../../domain/entities/owner_restaurant.dart';

/// Base class for OwnerPanel states
abstract class OwnerPanelState extends Equatable {
  const OwnerPanelState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class OwnerPanelInitial extends OwnerPanelState {}

/// Loading stats
class OwnerStatsLoading extends OwnerPanelState {}

/// Stats loaded successfully
class OwnerStatsLoaded extends OwnerPanelState {
  final OwnerStats stats;

  const OwnerStatsLoaded({required this.stats});

  @override
  List<Object?> get props => [stats];
}

/// Loading restaurants
class OwnerRestaurantsLoading extends OwnerPanelState {}

/// Restaurants loaded successfully
class OwnerRestaurantsLoaded extends OwnerPanelState {
  final List<OwnerRestaurant> restaurants;

  const OwnerRestaurantsLoaded({required this.restaurants});

  @override
  List<Object?> get props => [restaurants];
}

/// Combined state with both stats and restaurants
class OwnerPanelDataLoaded extends OwnerPanelState {
  final OwnerStats stats;
  final List<OwnerRestaurant> restaurants;

  const OwnerPanelDataLoaded({
    required this.stats,
    required this.restaurants,
  });

  @override
  List<Object?> get props => [stats, restaurants];
}

/// Requesting owner upgrade
class OwnerUpgradeRequesting extends OwnerPanelState {}

/// Owner upgrade request submitted successfully
class OwnerUpgradeRequestSubmitted extends OwnerPanelState {}

/// Error state
class OwnerPanelError extends OwnerPanelState {
  final String message;

  const OwnerPanelError({required this.message});

  @override
  List<Object?> get props => [message];
}
