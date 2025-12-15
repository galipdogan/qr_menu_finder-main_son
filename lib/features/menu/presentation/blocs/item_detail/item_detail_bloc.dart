import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/menu_item.dart';
import '../../../domain/usecases/get_menu_item_by_id.dart';
import '../../../../restaurant/domain/entities/restaurant.dart';
import '../../../../restaurant/domain/usecases/get_restaurant_by_id.dart';
//import '../../../../../core/error/failures.dart';

part 'item_detail_event.dart';
part 'item_detail_state.dart';

class ItemDetailBloc extends Bloc<ItemDetailEvent, ItemDetailState> {
  final GetMenuItemById _getMenuItemById;
  final GetRestaurantById _getRestaurantById;

  ItemDetailBloc({
    required GetMenuItemById getMenuItemById,
    required GetRestaurantById getRestaurantById,
  }) : _getMenuItemById = getMenuItemById,
       _getRestaurantById = getRestaurantById,
       super(ItemDetailInitial()) {
    on<LoadItemDetail>(_onLoadItemDetail);
  }

  Future<void> _onLoadItemDetail(
    LoadItemDetail event,
    Emitter<ItemDetailState> emit,
  ) async {
    emit(ItemDetailLoading());

    try {
      // Get menu item by ID
      final itemResult = await _getMenuItemById(
        MenuItemByIdParams(itemId: event.itemId),
      );

      await itemResult.fold(
        (failure) async {
          emit(ItemDetailError(failure.userMessage));
        },
        (item) async {
          // Get restaurant info
          final restaurantResult = await _getRestaurantById(
            RestaurantByIdParams(id: event.restaurantId),
          );

          restaurantResult.fold(
            (failure) {
              // Item loaded but restaurant failed - still show item
              emit(ItemDetailLoaded(item: item, restaurant: null));
            },
            (restaurant) {
              emit(ItemDetailLoaded(item: item, restaurant: restaurant));
            },
          );
        },
      );
    } catch (e) {
      emit(ItemDetailError('Ürün yüklenirken hata oluştu: ${e.toString()}'));
    }
  }
}
