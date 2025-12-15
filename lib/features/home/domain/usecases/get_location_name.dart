import 'package:dartz/dartz.dart';
import '../../../../core/error/error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/location.dart';
import '../repositories/location_repository.dart';

class GetLocationName implements UseCase<String, GetLocationNameParams> {
  final LocationRepository repository;

  GetLocationName(this.repository);

  @override
  Future<Either<Failure, String>> call(GetLocationNameParams params) async {
    return await repository.getLocationName(params.location);
  }
}

class GetLocationNameParams {
  final Location location;

  GetLocationNameParams({required this.location});
}