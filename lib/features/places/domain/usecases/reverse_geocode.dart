import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/places/domain/repositories/places_repository.dart';
import 'package:qr_menu_finder/features/home/domain/entities/place_suggestion.dart';

class ReverseGeocode implements UseCase<PlaceSuggestion, ReverseGeocodeParams> {
  final PlacesRepository repository;

  ReverseGeocode(this.repository);

  @override
  Future<Either<Failure, PlaceSuggestion>> call(ReverseGeocodeParams params) async {
    return await repository.reverseGeocode(
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}

class ReverseGeocodeParams extends Equatable {
  final double latitude;
  final double longitude;

  const ReverseGeocodeParams({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [latitude, longitude];
}
