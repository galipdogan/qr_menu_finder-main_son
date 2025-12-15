import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/menu_item.dart';
import '../repositories/menu_repository.dart';

/// Get menu items by restaurant use case
class GetMenuItemsByRestaurant implements UseCase<List<MenuItem>, MenuItemsByRestaurantParams> {
  final MenuRepository repository;

  GetMenuItemsByRestaurant(this.repository);

  @override
  Future<Either<Failure, List<MenuItem>>> call(MenuItemsByRestaurantParams params) async {
    return await repository.getMenuItemsByRestaurantId(
      restaurantId: params.restaurantId,
      category: params.category,
      limit: params.limit,
    );
  }
}

/// Parameters for get menu items by restaurant use case
class MenuItemsByRestaurantParams extends Equatable {
  final String restaurantId;
  final String? category;
  final int limit;

  const MenuItemsByRestaurantParams({
    required this.restaurantId,
    this.category,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [restaurantId, category, limit];
}