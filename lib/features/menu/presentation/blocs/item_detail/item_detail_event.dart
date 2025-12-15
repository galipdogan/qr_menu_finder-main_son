part of 'item_detail_bloc.dart';

abstract class ItemDetailEvent extends Equatable {
  const ItemDetailEvent();

  @override
  List<Object> get props => [];
}

/// Event to load item and restaurant details
class LoadItemDetail extends ItemDetailEvent {
  final String itemId;
  final String restaurantId;

  const LoadItemDetail({
    required this.itemId,
    required this.restaurantId,
  });

  @override
  List<Object> get props => [itemId, restaurantId];
}
