import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/menu_item.dart';
import '../repositories/menu_repository.dart';

/// Get menu item by ID use case
class GetMenuItemById implements UseCase<MenuItem, MenuItemByIdParams> {
  final MenuRepository repository;

  GetMenuItemById(this.repository);

  @override
  Future<Either<Failure, MenuItem>> call(MenuItemByIdParams params) async {
    return await repository.getMenuItemById(params.itemId);
  }
}

/// Parameters for get menu item by ID use case
class MenuItemByIdParams extends Equatable {
  final String itemId;

  const MenuItemByIdParams({required this.itemId});

  @override
  List<Object> get props => [itemId];
}