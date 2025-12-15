part of 'location_selection_bloc.dart';

abstract class LocationSelectionState extends Equatable {
  const LocationSelectionState();

  @override
  List<Object?> get props => [];
}

class LocationSelectionInitial extends LocationSelectionState {}

class LocationSelectionLoading extends LocationSelectionState {}

class LocationSelectionError extends LocationSelectionState {
  final String message;

  const LocationSelectionError(this.message);

  @override
  List<Object> get props => [message];
}

class LocationSelectionLoaded extends LocationSelectionState {
  final List<TurkeyLocation> allLocations;
  final List<TurkeyLocation> cities;
  final List<TurkeyLocation> districts;
  final List<TurkeyLocation> neighborhoods;
  final TurkeyLocation? selectedCity;
  final TurkeyLocation? selectedDistrict;
  final TurkeyLocation? selectedNeighborhood;

  const LocationSelectionLoaded({
    required this.allLocations,
    required this.cities,
    this.districts = const [],
    this.neighborhoods = const [],
    this.selectedCity,
    this.selectedDistrict,
    this.selectedNeighborhood,
  });

  @override
  List<Object?> get props => [
    allLocations,
    cities,
    districts,
    neighborhoods,
    selectedCity,
    selectedDistrict,
    selectedNeighborhood,
  ];

  LocationSelectionLoaded copyWith({
    List<TurkeyLocation>? allLocations,
    List<TurkeyLocation>? cities,
    List<TurkeyLocation>? districts,
    List<TurkeyLocation>? neighborhoods,
    TurkeyLocation? selectedCity,
    TurkeyLocation? selectedDistrict,
    TurkeyLocation? selectedNeighborhood,
  }) {
    return LocationSelectionLoaded(
      allLocations: allLocations ?? this.allLocations,
      cities: cities ?? this.cities,
      districts: districts ?? this.districts,
      neighborhoods: neighborhoods ?? this.neighborhoods,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
      selectedNeighborhood: selectedNeighborhood ?? this.selectedNeighborhood,
    );
  }
}

class LocationSelectionConfirmedState extends LocationSelectionState {
  final TurkeyLocation selectedLocation;

  const LocationSelectionConfirmedState(this.selectedLocation);

  @override
  List<Object> get props => [selectedLocation];
}