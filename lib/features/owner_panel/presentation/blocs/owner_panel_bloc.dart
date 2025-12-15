import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_owner_stats.dart';
import '../../domain/usecases/get_owner_restaurants.dart';
import '../../domain/usecases/request_owner_upgrade.dart';
import 'owner_panel_event.dart';
import 'owner_panel_state.dart';

/// BLoC for Owner Panel feature
class OwnerPanelBloc extends Bloc<OwnerPanelEvent, OwnerPanelState> {
  final GetOwnerStats getOwnerStats;
  final GetOwnerRestaurants getOwnerRestaurants;
  final RequestOwnerUpgrade requestOwnerUpgrade;

  OwnerPanelBloc({
    required this.getOwnerStats,
    required this.getOwnerRestaurants,
    required this.requestOwnerUpgrade,
  }) : super(OwnerPanelInitial()) {
    on<OwnerStatsLoadRequested>(_onOwnerStatsLoadRequested);
    on<OwnerRestaurantsLoadRequested>(_onOwnerRestaurantsLoadRequested);
    on<OwnerUpgradeRequested>(_onOwnerUpgradeRequested);
    on<OwnerPanelRefreshRequested>(_onOwnerPanelRefreshRequested);
  }

  Future<void> _onOwnerStatsLoadRequested(
    OwnerStatsLoadRequested event,
    Emitter<OwnerPanelState> emit,
  ) async {
    emit(OwnerStatsLoading());

    final result = await getOwnerStats(event.ownerId);

    result.fold(
      (failure) => emit(OwnerPanelError(message: failure.message)),
      (stats) => emit(OwnerStatsLoaded(stats: stats)),
    );
  }

  Future<void> _onOwnerRestaurantsLoadRequested(
    OwnerRestaurantsLoadRequested event,
    Emitter<OwnerPanelState> emit,
  ) async {
    emit(OwnerRestaurantsLoading());

    final result = await getOwnerRestaurants(event.ownerId);

    result.fold(
      (failure) => emit(OwnerPanelError(message: failure.message)),
      (restaurants) =>
          emit(OwnerRestaurantsLoaded(restaurants: restaurants)),
    );
  }

  Future<void> _onOwnerUpgradeRequested(
    OwnerUpgradeRequested event,
    Emitter<OwnerPanelState> emit,
  ) async {
    emit(OwnerUpgradeRequesting());

    final result = await requestOwnerUpgrade(event.userId);

    result.fold(
      (failure) => emit(OwnerPanelError(message: failure.message)),
      (_) => emit(OwnerUpgradeRequestSubmitted()),
    );
  }

  Future<void> _onOwnerPanelRefreshRequested(
    OwnerPanelRefreshRequested event,
    Emitter<OwnerPanelState> emit,
  ) async {
    // Load both stats and restaurants
    emit(OwnerStatsLoading());

    final statsResult = await getOwnerStats(event.ownerId);
    final restaurantsResult = await getOwnerRestaurants(event.ownerId);

    if (statsResult.isLeft() || restaurantsResult.isLeft()) {
      final errorMessage = statsResult.fold(
        (failure) => failure.message,
        (_) => restaurantsResult.fold(
          (failure) => failure.message,
          (_) => 'Unknown error',
        ),
      );
      emit(OwnerPanelError(message: errorMessage));
      return;
    }

    final stats = statsResult.getOrElse(() => throw Exception());
    final restaurants = restaurantsResult.getOrElse(() => throw Exception());

    emit(OwnerPanelDataLoaded(stats: stats, restaurants: restaurants));
  }
}
