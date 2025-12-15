import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/menu_item.dart';
import '../repositories/menu_repository.dart';

/// Get menu items by category use case
class GetMenuItemsByCategory implements UseCase<List<MenuItem>, MenuItemsByCategoryParams> {
  final MenuRepository repository;

  GetMenuItemsByCategory(this.repository);

  @override
  Future<Either<Failure, List<MenuItem>>> call(MenuItemsByCategoryParams params) async {
    return await repository.getMenuItemsByCategory(
      category: params.category,
      limit: params.limit,
    );
  }
}

/// Parameters for menu items by category use case
class MenuItemsByCategoryParams extends Equatable {
  final String category;
  final int limit;

  const MenuItemsByCategoryParams({
    required this.category,
    this.limit = 20,
  });

  @override
  List<Object> get props => [category, limit];
}