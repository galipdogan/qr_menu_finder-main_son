import 'package:equatable/equatable.dart';
import '../../domain/entities/restaurant.dart';

// States
abstract class RestaurantState extends Equatable {
  const RestaurantState();

  @override
  List<Object?> get props => [];
}

class RestaurantInitial extends RestaurantState {}

class RestaurantLoading extends RestaurantState {}

class RestaurantListLoaded extends RestaurantState {
  final List<Restaurant> restaurants;

  const RestaurantListLoaded({required this.restaurants});

  @override
  List<Object> get props => [restaurants];
}

class RestaurantDetailLoaded extends RestaurantState {
  final Restaurant restaurant;

  const RestaurantDetailLoaded({required this.restaurant});

  @override
  List<Object> get props => [restaurant];
}

class RestaurantListEmpty extends RestaurantState {
  final String message;

  const RestaurantListEmpty({required this.message});

  @override
  List<Object> get props => [message];
}

class RestaurantError extends RestaurantState {
  final String message;

  const RestaurantError({required this.message});

  @override
  List<Object> get props => [message];
}

class RestaurantOperationSuccess extends RestaurantState {
  final String message;

  const RestaurantOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}
