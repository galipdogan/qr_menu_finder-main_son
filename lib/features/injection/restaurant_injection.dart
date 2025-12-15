import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/restaurant/data/datasources/restaurant_remote_data_source.dart';
import '../../features/restaurant/data/datasources/restaurant_remote_data_source_impl.dart';
import '../../features/restaurant/data/repositories/restaurant_repository_impl.dart';
import '../../features/restaurant/domain/repositories/restaurant_repository.dart';

import '../../features/maps/data/datasources/nominatim_remote_data_source.dart';
import '../../features/maps/data/datasources/openstreetmap_details_remote_data_source.dart';

import '../../features/restaurant/domain/usecases/get_nearby_restaurants.dart';
import '../../features/restaurant/domain/usecases/search_restaurants.dart';
import '../../features/restaurant/domain/usecases/get_restaurant_by_id.dart';
import '../../features/restaurant/domain/usecases/create_restaurant.dart';
import '../../features/restaurant/domain/usecases/update_restaurant.dart';
import '../../features/restaurant/domain/usecases/delete_restaurant.dart';
import '../../features/restaurant/domain/usecases/get_restaurants_by_owner_id.dart';
import '../../features/restaurant/domain/usecases/get_restaurants_by_category.dart';
import '../../features/restaurant/domain/usecases/get_popular_restaurants.dart';

import '../../features/restaurant/presentation/blocs/restaurant_bloc.dart';

final sl = GetIt.instance;

Future<void> initRestaurant() async {
  // Remote Data Source
  sl.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(
      firestore: sl(),
      nominatimRemoteDataSource: sl(),
      osmDetailsService: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(remoteDataSource: sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => GetNearbyRestaurants(sl()));
  sl.registerLazySingleton(() => SearchRestaurants(sl()));
  sl.registerLazySingleton(() => GetRestaurantById(sl()));
  sl.registerLazySingleton(() => CreateRestaurant(sl()));
  sl.registerLazySingleton(() => UpdateRestaurant(sl()));
  sl.registerLazySingleton(() => DeleteRestaurant(sl()));
  sl.registerLazySingleton(() => GetRestaurantsByOwnerId(sl()));
  sl.registerLazySingleton(() => GetRestaurantsByCategory(sl()));
  sl.registerLazySingleton(() => GetPopularRestaurants(sl()));

  // Bloc
  sl.registerFactory(
    () => RestaurantBloc(
      getNearbyRestaurants: sl(),
      searchRestaurants: sl(),
      getRestaurantById: sl(),
      createRestaurant: sl(),
      updateRestaurant: sl(),
      deleteRestaurant: sl(),
      getRestaurantsByOwnerId: sl(),
      getRestaurantsByCategory: sl(),
      getPopularRestaurants: sl(),
    ),
  );
}
