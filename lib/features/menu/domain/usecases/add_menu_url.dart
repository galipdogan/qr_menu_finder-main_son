import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/menu_repository.dart';

class AddMenuUrl implements UseCase<void, AddMenuUrlParams> {
  final MenuRepository repository;

  AddMenuUrl(this.repository);

  @override
  Future<Either<Failure, void>> call(AddMenuUrlParams params) async {
    return await repository.addMenuUrl(
      restaurantId: params.restaurantId,
      url: params.url,
      type: params.type,
    );
  }
}

class AddMenuUrlParams extends Equatable {
  final String restaurantId;
  final String url;
  final String type;

  const AddMenuUrlParams({
    required this.restaurantId,
    required this.url,
    required this.type,
  });

  @override
  List<Object?> get props => [restaurantId, url, type];
}
