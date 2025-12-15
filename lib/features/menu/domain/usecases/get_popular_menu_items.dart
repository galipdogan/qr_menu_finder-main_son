import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/menu_item.dart';
import '../repositories/menu_repository.dart';

/// Get popular menu items use case
class GetPopularMenuItems implements UseCase<List<MenuItem>, PopularMenuItemsParams> {
  final MenuRepository repository;

  GetPopularMenuItems(this.repository);

  @override
  Future<Either<Failure, List<MenuItem>>> call(PopularMenuItemsParams params) async {
    return await repository.getPopularMenuItems(limit: params.limit);
  }
}

/// Parameters for popular menu items use case
class PopularMenuItemsParams extends Equatable {
  final int limit;

  const PopularMenuItemsParams({this.limit = 10});

  @override
  List<Object> get props => [limit];
}