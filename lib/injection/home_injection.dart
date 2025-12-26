import 'package:get_it/get_it.dart';

import '../features/home/data/datasources/location_remote_data_source.dart';
import '../features/home/data/repositories/location_repository_impl.dart';
import '../features/home/domain/repositories/location_repository.dart';
import '../features/home/domain/usecases/get_current_location.dart';
import '../features/home/domain/usecases/get_location_name.dart';
import '../features/home/domain/usecases/get_turkey_locations.dart';
import '../features/home/domain/usecases/search_places.dart';
import '../features/home/presentation/blocs/home_bloc.dart';
import '../features/home/presentation/blocs/location_selection/location_selection_bloc.dart';
import '../features/home/presentation/blocs/search/search_bloc.dart'
    as home_search;

void injectHome(GetIt sl) {
  sl.registerFactory(
    () => HomeBloc(
      getCurrentLocation: sl(),
      getLocationName: sl(),
      getNearbyRestaurants: sl(),
      getUserFavorites: sl(),
      toggleFavorite: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetCurrentLocation(sl()));
  sl.registerLazySingleton(() => GetLocationName(sl()));
  sl.registerLazySingleton(() => SearchPlaces(sl()));
  sl.registerLazySingleton(() => GetTurkeyLocations(sl()));

  sl.registerFactory(() => home_search.SearchBloc(searchPlaces: sl()));

  sl.registerFactory(() => LocationSelectionBloc(getTurkeyLocations: sl()));

  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(
      nominatimService: sl(),
      //turkeyLocationRemoteDataSource: sl(),
      photonRemoteDataSource: sl(),
      restaurantRemoteDataSource: sl(),
    ),
  );
}
