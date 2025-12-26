import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/maps/data/datasources/photon_remote_data_source.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/services/nominatim_service.dart';
import '../../../../core/models/nominatim_place.dart';
import '../../../../core/models/place_result.dart';
import '../../../restaurant/data/datasources/restaurant_remote_data_source.dart';
import '../../domain/entities/location.dart';
import '../models/location_model.dart';
import '../../domain/entities/place_suggestion.dart';
import '../../domain/entities/turkey_location.dart';

abstract class LocationRemoteDataSource {
  Future<Location> getCurrentLocation();
  Future<String> getLocationName(Location location);
  Future<List<PlaceSuggestion>> searchPlaces({
    required String query,
    double? latitude,
    double? longitude,
    int limit = 10,
  });
  Future<List<TurkeyLocation>> getTurkeyLocations();
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final NominatimService nominatimService;
  //final TurkeyLocationRemoteDataSource turkeyLocationRemoteDataSource;
  final PhotonRemoteDataSource photonRemoteDataSource; // New dependency
  final RestaurantRemoteDataSource restaurantRemoteDataSource; // New dependency

  LocationRemoteDataSourceImpl({
    required this.nominatimService,
    //required this.turkeyLocationRemoteDataSource, // Correct
    required this.photonRemoteDataSource, // Correct
    required this.restaurantRemoteDataSource, // Correct
  });

  @override
  Future<Location> getCurrentLocation() async {
    // Check and request location permission directly here
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
  
  @override
  Future<String> getLocationName(Location location) {
    // TODO: implement getLocationName
    throw UnimplementedError();
  }

  @override
  Future<List<TurkeyLocation>> getTurkeyLocations() async {
    // TODO: Implement Turkey locations
    // For now, return empty list
    return [];
  }


  @override
  Future<List<PlaceSuggestion>> searchPlaces({
    required String query,
    double? latitude,
    double? longitude,
    int limit = 10,
  }) async {
    if (query.isEmpty || query.length < 2) return [];

    final Set<PlaceResult> allResults = {};

    try {
      // 1. Try Photon API (fast autocomplete)
      final photonResults = await photonRemoteDataSource.searchPlaces(
        query,
        latitude: latitude,
        longitude: longitude,
        limit: limit,
      );
      allResults.addAll(photonResults);
      if (allResults.length >= limit) {
        return allResults.take(limit).map(_toPlaceSuggestion).toList();
      }
    } catch (e) {
      AppLogger.w('Photon search failed: $e');
    }

    try {
      // 2. Fallback to Nominatim API (more comprehensive)
      final nominatimResults = await nominatimService.searchByText(
        query: query,
        latitude: latitude,
        longitude: longitude,
        limit: limit - allResults.length,
      );
      allResults.addAll(nominatimResults.map(_nominatimToPlaceResult));
      if (allResults.length >= limit) {
        return allResults.take(limit).map(_toPlaceSuggestion).toList();
      }
    } catch (e) {
      AppLogger.w('Nominatim search failed: $e');
    }

    try {
      // 3. Fallback to Firestore (for restaurants)
      final firestoreResults = await restaurantRemoteDataSource
          .searchRestaurantsFromFirestore(
            query,
            limit: limit - allResults.length,
          );
      allResults.addAll(firestoreResults);
      if (allResults.length >= limit) {
        return allResults.take(limit).map(_toPlaceSuggestion).toList();
      }
    } catch (e) {
      AppLogger.w('Firestore search failed: $e');
    }

    return allResults.take(limit).map(_toPlaceSuggestion).toList();
  }

  PlaceSuggestion _toPlaceSuggestion(PlaceResult result) {
    return PlaceSuggestion(
      id: result.placeId,
      name: result.name,
      address: result.displayName, // Use displayName for full address
      latitude: result.latitude,
      longitude: result.longitude,
      type: result.type,
    );
  }

  PlaceResult _nominatimToPlaceResult(NominatimPlace place) {
    return PlaceResult(
      placeId: place.placeId.toString(),
      name: place.displayName.split(',').first.trim(),
      displayName: place.displayName,
      latitude: place.latitude,
      longitude: place.longitude,
      type: place.type ?? 'place',
    );
  }

  // @override
  // Future<List<TurkeyLocation>> getTurkeyLocations() async {
  //   final cities = turkeyLocationRemoteDataSource.getMajorCities();
  //   final List<TurkeyLocation> allLocations = [];

  //   for (final city in cities) {
  //     final coords = turkeyLocationRemoteDataSource.getCityCoordinates(city);
  //     allLocations.add(
  //       TurkeyLocation(
  //         id: 'city_${city.toLowerCase()}',
  //         name: city,
  //         type: 'city',
  //         latitude: coords?['lat'] ?? 0.0,
  //         longitude: coords?['lng'] ?? 0.0,
  //       ),
  //     );
  //     // Optionally fetch districts and neighborhoods if needed for full hierarchy
  //     // For now, just add cities to avoid excessive API calls
  //   }
  //   return allLocations;
  // }
}
