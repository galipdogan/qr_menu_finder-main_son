import 'package:get_it/get_it.dart';
import 'package:qr_menu_finder/core/cache/cache_manager.dart';
import 'package:qr_menu_finder/core/network/network_info.dart';
import 'package:qr_menu_finder/features/restaurant/data/datasources/restaurant_local_data_source.dart';

import '../core/maps/data/datasources/openstreetmap_details_remote_data_source.dart';
import '../features/restaurant/data/datasources/restaurant_remote_data_source.dart';
import '../features/restaurant/data/repositories/restaurant_repository_impl.dart';
import '../features/restaurant/domain/repositories/restaurant_repository.dart';
import '../features/restaurant/domain/usecases/create_restaurant.dart';
import '../features/restaurant/domain/usecases/get_nearby_restaurants.dart';
import '../features/restaurant/domain/usecases/get_restaurant_by_id.dart';
import '../features/restaurant/domain/usecases/search_restaurants.dart';
import '../features/restaurant/presentation/blocs/restaurant_bloc.dart';

void injectRestaurant(GetIt sl) {
  sl.registerFactory(
    () => RestaurantBloc(
      getNearbyRestaurants: sl(),
      searchRestaurants: sl(),
      getRestaurantById: sl(),
      createRestaurant: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetNearbyRestaurants(sl()));
  sl.registerLazySingleton(() => SearchRestaurants(sl()));
  sl.registerLazySingleton(() => GetRestaurantById(sl()));
  sl.registerLazySingleton(() => CreateRestaurant(sl()));

  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
      mappr: sl(),
    ),
  );

  sl.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(
      firestore: sl(),
      nominatimService: sl(),
      osmDetailsService: sl<OpenStreetMapDetailsRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<RestaurantLocalDataSource>(
    () => RestaurantLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CacheManager<Map<String, dynamic>>>(
    () => CacheManager(sl()),
  );
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
}
