import 'package:equatable/equatable.dart';
import '../../domain/entities/favorite_item.dart';

/// Base class for all favorites states
abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any favorites are loaded
class FavoritesInitial extends FavoritesState {}

/// State when loading favorites
class FavoritesLoading extends FavoritesState {}

/// State when favorites are successfully loaded
class FavoritesLoaded extends FavoritesState {
  final List<FavoriteItem> favorites;

  const FavoritesLoaded({required this.favorites});

  bool get isEmpty => favorites.isEmpty;

  @override
  List<Object> get props => [favorites];
}

/// State when an error occurs
class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError({required this.message});

  @override
  List<Object> get props => [message];
}

/// State when a favorite action completes successfully
/// 
/// Used to show feedback to user without changing the main state
class FavoriteActionSuccess extends FavoritesState {
  final String message;
  final bool isFavorited;
  final String itemId;

  const FavoriteActionSuccess({
    required this.message,
    required this.isFavorited,
    required this.itemId,
  });

  @override
  List<Object> get props => [message, isFavorited, itemId];
}
