import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/favorite_item.dart';
import '../../domain/usecases/add_favorite.dart';
import '../../domain/usecases/get_user_favorites.dart';
import '../../domain/usecases/remove_favorite.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../../../core/utils/app_logger.dart';

// Events
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class FavoritesLoadRequested extends FavoritesEvent {
  final String userId;
  final FavoriteType? type;

  const FavoritesLoadRequested({
    required this.userId,
    this.type,
  });

  @override
  List<Object?> get props => [userId, type];
}

class FavoriteToggleRequested extends FavoritesEvent {
  final String userId;
  final String itemId;
  final FavoriteType type;

  const FavoriteToggleRequested({
    required this.userId,
    required this.itemId,
    required this.type,
  });

  @override
  List<Object> get props => [userId, itemId, type];
}

class FavoriteAddRequested extends FavoritesEvent {
  final String userId;
  final String itemId;
  final FavoriteType type;

  const FavoriteAddRequested({
    required this.userId,
    required this.itemId,
    required this.type,
  });

  @override
  List<Object> get props => [userId, itemId, type];
}

class FavoriteRemoveRequested extends FavoritesEvent {
  final String favoriteId;

  const FavoriteRemoveRequested({required this.favoriteId});

  @override
  List<Object> get props => [favoriteId];
}

// States
abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<FavoriteItem> favorites;

  const FavoritesLoaded({required this.favorites});

  bool get isEmpty => favorites.isEmpty;

  @override
  List<Object> get props => [favorites];
}

class FavoriteToggling extends FavoritesState {
  final List<FavoriteItem> currentFavorites;
  final String itemId;

  const FavoriteToggling({
    required this.currentFavorites,
    required this.itemId,
  });

  @override
  List<Object> get props => [currentFavorites, itemId];
}

class FavoriteToggled extends FavoritesState {
  final bool isFavorited;
  final String itemId;

  const FavoriteToggled({
    required this.isFavorited,
    required this.itemId,
  });

  @override
  List<Object> get props => [isFavorited, itemId];
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetUserFavorites getUserFavorites;
  final AddFavorite addFavorite;
  final RemoveFavorite removeFavorite;
  final ToggleFavorite toggleFavorite;

  FavoritesBloc({
    required this.getUserFavorites,
    required this.addFavorite,
    required this.removeFavorite,
    required this.toggleFavorite,
  }) : super(FavoritesInitial()) {
    on<FavoritesLoadRequested>(_onFavoritesLoadRequested);
    on<FavoriteToggleRequested>(_onFavoriteToggleRequested);
    on<FavoriteAddRequested>(_onFavoriteAddRequested);
    on<FavoriteRemoveRequested>(_onFavoriteRemoveRequested);
  }

  Future<void> _onFavoritesLoadRequested(
    FavoritesLoadRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    AppLogger.i('FavoritesBloc: Loading favorites for user ${event.userId}, type: ${event.type}');
    emit(FavoritesLoading());

    final result = await getUserFavorites(
      GetUserFavoritesParams(
        userId: event.userId,
        type: event.type,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.e('FavoritesBloc: Failed to load favorites', error: failure.message);
        emit(FavoritesError(message: failure.message));
      },
      (favorites) {
        AppLogger.i('FavoritesBloc: Loaded ${favorites.length} favorites');
        emit(FavoritesLoaded(favorites: favorites));
      },
    );
  }

  Future<void> _onFavoriteToggleRequested(
    FavoriteToggleRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    AppLogger.i('FavoritesBloc: Toggle requested for item ${event.itemId} by user ${event.userId}');
    final currentState = state;
    List<FavoriteItem> currentFavorites = [];

    if (currentState is FavoritesLoaded) {
      currentFavorites = currentState.favorites;
      AppLogger.d('   Current favorites count: ${currentFavorites.length}');
      emit(FavoriteToggling(
        currentFavorites: currentFavorites,
        itemId: event.itemId,
      ));
    }

    final result = await toggleFavorite(
      ToggleFavoriteParams(
        userId: event.userId,
        itemId: event.itemId,
        type: event.type,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.e('FavoritesBloc: Toggle failed for item ${event.itemId}', error: failure.message);
        emit(FavoritesError(message: failure.message));
        // Restore previous state
        if (currentFavorites.isNotEmpty) {
          emit(FavoritesLoaded(favorites: currentFavorites));
        }
      },
      (isFavorited) async {
        AppLogger.i('   Toggle result: isFavorited = $isFavorited');
        
        // Check if emit is still valid before proceeding
        if (emit.isDone) return;
        
        if (isFavorited) {
          AppLogger.d('   Item was ADDED - reloading favorites to get new item with ID');
          // Item was added to favorites - reload to get the new item with its ID
          final reloadResult = await getUserFavorites(
            GetUserFavoritesParams(userId: event.userId, type: event.type),
          );
          
          // Check again before emitting
          if (emit.isDone) return;
          
          reloadResult.fold(
            (failure) {
              AppLogger.e('FavoritesBloc: Failed to reload after add', error: failure.message);
              emit(FavoritesError(message: failure.message));
              // Restore previous state
              if (currentFavorites.isNotEmpty) {
                emit(FavoritesLoaded(favorites: currentFavorites));
              }
            },
            (favorites) {
              AppLogger.i('FavoritesBloc: Item ADDED - now ${favorites.length} favorites');
              emit(FavoritesLoaded(favorites: favorites));
            },
          );
        } else {
          AppLogger.d('   Item was REMOVED - filtering from current list');
          // Item was removed - just filter it out from current list
          final updatedFavorites = currentFavorites
              .where((fav) => fav.itemId != event.itemId)
              .toList();
          AppLogger.i('FavoritesBloc: Item REMOVED - now ${updatedFavorites.length} favorites');
          emit(FavoritesLoaded(favorites: updatedFavorites));
        }
      },
    );
  }

  Future<void> _onFavoriteAddRequested(
    FavoriteAddRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await addFavorite(
      AddFavoriteParams(
        userId: event.userId,
        itemId: event.itemId,
        type: event.type,
      ),
    );

    result.fold(
      (failure) => emit(FavoritesError(message: failure.message)),
      (_) {
        // Reload favorites after add
        add(FavoritesLoadRequested(userId: event.userId));
      },
    );
  }

  Future<void> _onFavoriteRemoveRequested(
    FavoriteRemoveRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    AppLogger.i('FavoritesBloc: Remove requested for favorite ${event.favoriteId}');
    final result = await removeFavorite(
      RemoveFavoriteParams(favoriteId: event.favoriteId),
    );

    result.fold(
      (failure) {
        AppLogger.e('FavoritesBloc: Failed to remove favorite ${event.favoriteId}', error: failure.message);
        emit(FavoritesError(message: failure.message));
      },
      (_) {
        AppLogger.d('   Remove successful - updating state');
        // Remove from current state without reload
        if (state is FavoritesLoaded) {
          final currentFavorites = (state as FavoritesLoaded).favorites;
          AppLogger.d('   Current favorites count: ${currentFavorites.length}');

          // Find the removed item's itemId for the FavoriteToggled event
          final removedFavorite = currentFavorites.firstWhere(
            (f) => f.id == event.favoriteId,
            orElse: () => currentFavorites.first, // Fallback
          );

          final updatedFavorites = currentFavorites
              .where((f) => f.id != event.favoriteId)
              .toList();
          AppLogger.i('FavoritesBloc: Favorite removed - now ${updatedFavorites.length} favorites');

          // Emit FavoriteToggled first so UI can show the message
          emit(FavoriteToggled(isFavorited: false, itemId: removedFavorite.itemId));
          emit(FavoritesLoaded(favorites: updatedFavorites));
        }
      },
    );
  }
}
