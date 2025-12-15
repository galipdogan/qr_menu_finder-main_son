part of 'item_detail_bloc.dart';

abstract class ItemDetailState extends Equatable {
  const ItemDetailState();

  @override
  List<Object?> get props => [];
}

class ItemDetailInitial extends ItemDetailState {}

class ItemDetailLoading extends ItemDetailState {}

class ItemDetailLoaded extends ItemDetailState {
  final MenuItem item;
  final Restaurant? restaurant;

  const ItemDetailLoaded({
    required this.item,
    this.restaurant,
  });

  @override
  List<Object?> get props => [item, restaurant];
}

class ItemDetailError extends ItemDetailState {
  final String message;

  const ItemDetailError(this.message);

  @override
  List<Object> get props => [message];
}
