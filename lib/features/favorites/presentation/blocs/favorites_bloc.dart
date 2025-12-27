import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/favorite_item.dart';
import '../../domain/usecases/add_favorite.dart';
import '../../domain/usecases/get_user_favorites.dart';
import '../../domain/usecases/remove_favorite.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../../../core/utils/app_logger.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

/// FavoritesBloc - Manages favorites state
/// 
/// Refactored for better maintainability and clearer state management
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
    AppLogger.i(
      'FavoritesBloc: Loading favorites for user ${event.userId}, type: ${event.type}',
    );
    emit(FavoritesLoading());

    final result = await getUserFavorites(
      GetUserFavoritesParams(
        userId: event.userId,
        type: event.type,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.e(
          'FavoritesBloc: Failed to load favorites',
          error: failure.message,
        );
        emit(FavoritesError(message: failure.userMessage));
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
    AppLogger.i(
      'FavoritesBloc: Toggle requested for item ${event.itemId} by user ${event.userId}',
    );

    // Store current state for rollback
    final currentState = state;
    final currentFavorites = currentState is FavoritesLoaded
        ? currentState.favorites
        : <FavoriteItem>[];

    final result = await toggleFavorite(
      ToggleFavoriteParams(
        userId: event.userId,
        itemId: event.itemId,
        type: event.type,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.e(
          'FavoritesBloc: Toggle failed for item ${event.itemId}',
          error: failure.message,
        );
        emit(FavoritesError(message: failure.userMessage));
        
        // Restore previous state
        if (currentFavorites.isNotEmpty) {
          emit(FavoritesLoaded(favorites: currentFavorites));
        }
      },
      (isFavorited) async {
        AppLogger.i('FavoritesBloc: Toggle result - isFavorited: $isFavorited');

        // Emit success message
        emit(FavoriteActionSuccess(
          message: isFavorited
              ? 'Favorilere eklendi'
              : 'Favorilerden kaldırıldı',
          isFavorited: isFavorited,
          itemId: event.itemId,
        ));

        // Reload favorites to get updated list
        final reloadResult = await getUserFavorites(
          GetUserFavoritesParams(userId: event.userId, type: event.type),
        );

        reloadResult.fold(
          (failure) {
            AppLogger.e(
              'FavoritesBloc: Failed to reload after toggle',
              error: failure.message,
            );
            // Keep the current state on reload failure
            if (currentFavorites.isNotEmpty) {
              emit(FavoritesLoaded(favorites: currentFavorites));
            }
          },
          (favorites) {
            AppLogger.i(
              'FavoritesBloc: Reloaded - now ${favorites.length} favorites',
            );
            emit(FavoritesLoaded(favorites: favorites));
          },
        );
      },
    );
  }

  Future<void> _onFavoriteAddRequested(
    FavoriteAddRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    AppLogger.i(
      'FavoritesBloc: Add requested for item ${event.itemId} by user ${event.userId}',
    );

    final result = await addFavorite(
      AddFavoriteParams(
        userId: event.userId,
        itemId: event.itemId,
        type: event.type,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.e(
          'FavoritesBloc: Failed to add favorite',
          error: failure.message,
        );
        emit(FavoritesError(message: failure.userMessage));
      },
      (_) {
        AppLogger.i('FavoritesBloc: Favorite added successfully');
        
        // Emit success message
        emit(const FavoriteActionSuccess(
          message: 'Favorilere eklendi',
          isFavorited: true,
          itemId: '',
        ));

        // Reload favorites
        add(FavoritesLoadRequested(userId: event.userId, type: event.type));
      },
    );
  }

  Future<void> _onFavoriteRemoveRequested(
    FavoriteRemoveRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    AppLogger.i('FavoritesBloc: Remove requested for favorite ${event.favoriteId}');

    // Store current state for optimistic update
    final currentState = state;
    if (currentState is! FavoritesLoaded) return;

    final currentFavorites = currentState.favorites;
    
    // Find the favorite to remove
    final removedFavorite = currentFavorites.firstWhere(
      (f) => f.id == event.favoriteId,
      orElse: () => currentFavorites.first,
    );

    // Optimistic update - remove immediately
    final updatedFavorites = currentFavorites
        .where((f) => f.id != event.favoriteId)
        .toList();
    
    emit(FavoritesLoaded(favorites: updatedFavorites));

    final result = await removeFavorite(
      RemoveFavoriteParams(favoriteId: event.favoriteId),
    );

    result.fold(
      (failure) {
        AppLogger.e(
          'FavoritesBloc: Failed to remove favorite ${event.favoriteId}',
          error: failure.message,
        );
        
        // Rollback on error
        emit(FavoritesLoaded(favorites: currentFavorites));
        emit(FavoritesError(message: failure.userMessage));
      },
      (_) {
        AppLogger.i(
          'FavoritesBloc: Favorite removed - now ${updatedFavorites.length} favorites',
        );

        // Emit success message
        emit(FavoriteActionSuccess(
          message: 'Favorilerden kaldırıldı',
          isFavorited: false,
          itemId: removedFavorite.itemId,
        ));

        // Keep the updated state
        emit(FavoritesLoaded(favorites: updatedFavorites));
      },
    );
  }
}
