import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/turkey_location.dart';
import '../../../domain/usecases/get_turkey_locations.dart';
import '../../../../../core/usecases/usecase.dart';
part 'location_selection_event.dart';
part 'location_selection_state.dart';

class LocationSelectionBloc extends Bloc<LocationSelectionEvent, LocationSelectionState> {
  final GetTurkeyLocations getTurkeyLocations;

  LocationSelectionBloc({
    required this.getTurkeyLocations,
  }) : super(LocationSelectionInitial()) {
    on<LocationSelectionLoadRequested>(_onLoadRequested);
    on<LocationSelectionCityChanged>(_onCityChanged);
    on<LocationSelectionDistrictChanged>(_onDistrictChanged);
    on<LocationSelectionNeighborhoodChanged>(_onNeighborhoodChanged);
    on<LocationSelectionConfirmed>(_onLocationConfirmed);
  }

  Future<void> _onLoadRequested(
    LocationSelectionLoadRequested event,
    Emitter<LocationSelectionState> emit,
  ) async {
    emit(LocationSelectionLoading());

    final result = await getTurkeyLocations(NoParams());

    if (!emit.isDone) {
      result.fold(
        (failure) => emit(LocationSelectionError(failure.message)),
        (locations) {
          final cities = locations.where((loc) => loc.type == 'city').toList();
          cities.sort((a, b) => a.name.compareTo(b.name));
          
          emit(LocationSelectionLoaded(
            allLocations: locations,
            cities: cities,
            selectedCity: event.initialCity != null 
                ? cities.firstWhere(
                    (city) => city.name == event.initialCity,
                    orElse: () => cities.first,
                  )
                : null,
          ));
        },
      );
    }
  }

  void _onCityChanged(
    LocationSelectionCityChanged event,
    Emitter<LocationSelectionState> emit,
  ) {
    final currentState = state;
    if (currentState is LocationSelectionLoaded) {
      final districts = currentState.allLocations
          .where((loc) => loc.type == 'district' && loc.parentId == event.city.id)
          .toList();
      districts.sort((a, b) => a.name.compareTo(b.name));

      emit(currentState.copyWith(
        selectedCity: event.city,
        districts: districts,
        selectedDistrict: null,
        neighborhoods: [],
        selectedNeighborhood: null,
      ));
    }
  }

  void _onDistrictChanged(
    LocationSelectionDistrictChanged event,
    Emitter<LocationSelectionState> emit,
  ) {
    final currentState = state;
    if (currentState is LocationSelectionLoaded) {
      final neighborhoods = currentState.allLocations
          .where((loc) => loc.type == 'neighborhood' && loc.parentId == event.district.id)
          .toList();
      neighborhoods.sort((a, b) => a.name.compareTo(b.name));

      emit(currentState.copyWith(
        selectedDistrict: event.district,
        neighborhoods: neighborhoods,
        selectedNeighborhood: null,
      ));
    }
  }

  void _onNeighborhoodChanged(
    LocationSelectionNeighborhoodChanged event,
    Emitter<LocationSelectionState> emit,
  ) {
    final currentState = state;
    if (currentState is LocationSelectionLoaded) {
      emit(currentState.copyWith(
        selectedNeighborhood: event.neighborhood,
      ));
    }
  }

  void _onLocationConfirmed(
    LocationSelectionConfirmed event,
    Emitter<LocationSelectionState> emit,
  ) {
    final currentState = state;
    if (currentState is LocationSelectionLoaded) {
      final selectedLocation = currentState.selectedNeighborhood ?? 
                              currentState.selectedDistrict ?? 
                              currentState.selectedCity;
      
      if (selectedLocation != null) {
        emit(LocationSelectionConfirmedState(selectedLocation));
      }
    }
  }
}