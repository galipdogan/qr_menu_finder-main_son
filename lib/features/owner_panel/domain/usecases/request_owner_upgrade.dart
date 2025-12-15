import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/owner_panel_repository.dart';

/// Use case for requesting owner account upgrade
class RequestOwnerUpgrade implements UseCase<void, String> {
  final OwnerPanelRepository repository;

  RequestOwnerUpgrade(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.requestOwnerUpgrade(params);
  }
}
