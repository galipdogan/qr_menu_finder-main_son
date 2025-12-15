import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/menu_item.dart';
import '../repositories/menu_repository.dart';

/// Search menu items use case
class SearchMenuItems implements UseCase<List<MenuItem>, SearchMenuItemsParams> {
  final MenuRepository repository;

  SearchMenuItems(this.repository);

  @override
  Future<Either<Failure, List<MenuItem>>> call(SearchMenuItemsParams params) async {
    return await repository.searchMenuItems(
      query: params.query,
      restaurantId: params.restaurantId,
      category: params.category,
      limit: params.limit,
    );
  }
}

/// Parameters for search menu items use case
class SearchMenuItemsParams extends Equatable {
  final String query;
  final String? restaurantId;
  final String? category;
  final int limit;

  const SearchMenuItemsParams({
    required this.query,
    this.restaurantId,
    this.category,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, restaurantId, category, limit];
}