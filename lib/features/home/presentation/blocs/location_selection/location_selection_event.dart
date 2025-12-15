part of 'location_selection_bloc.dart';

abstract class LocationSelectionEvent extends Equatable {
  const LocationSelectionEvent();

  @override
  List<Object?> get props => [];
}

class LocationSelectionLoadRequested extends LocationSelectionEvent {
  final String? initialCity;

  const LocationSelectionLoadRequested({this.initialCity});

  @override
  List<Object?> get props => [initialCity];
}

class LocationSelectionCityChanged extends LocationSelectionEvent {
  final TurkeyLocation city;

  const LocationSelectionCityChanged(this.city);

  @override
  List<Object> get props => [city];
}

class LocationSelectionDistrictChanged extends LocationSelectionEvent {
  final TurkeyLocation district;

  const LocationSelectionDistrictChanged(this.district);

  @override
  List<Object> get props => [district];
}

class LocationSelectionNeighborhoodChanged extends LocationSelectionEvent {
  final TurkeyLocation neighborhood;

  const LocationSelectionNeighborhoodChanged(this.neighborhood);

  @override
  List<Object> get props => [neighborhood];
}

class LocationSelectionConfirmed extends LocationSelectionEvent {
  final TurkeyLocation location;

  const LocationSelectionConfirmed(this.location);

  @override
  List<Object> get props => [location];
}