import 'package:dartz/dartz.dart';
import '../../../../core/error/error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/turkey_location.dart';
import '../repositories/location_repository.dart';

class GetTurkeyLocations implements UseCase<List<TurkeyLocation>, NoParams> {
  final LocationRepository repository;

  GetTurkeyLocations(this.repository);

  @override
  Future<Either<Failure, List<TurkeyLocation>>> call(NoParams params) async {
    return await repository.getTurkeyLocations();
  }
}