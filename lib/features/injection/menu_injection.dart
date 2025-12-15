import 'package:get_it/get_it.dart';

import '../../features/menu/data/cache/menu_cache_service.dart';
import '../../features/menu/data/datasources/menu_firestore_queries.dart';
import '../../features/menu/data/datasources/menu_remote_data_source.dart';
import '../../features/menu/data/datasources/menu_remote_data_source_impl.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';

import '../../features/menu/domain/repositories/menu_repository.dart';
import '../../features/menu/domain/usecases/add_menu_photo.dart';
import '../../features/menu/domain/usecases/add_menu_url.dart';
import '../../features/menu/domain/usecases/get_menu_item_by_id.dart';
import '../../features/menu/domain/usecases/get_menu_items_by_category.dart';
import '../../features/menu/domain/usecases/get_menu_items_by_restaurant.dart';
import '../../features/menu/domain/usecases/get_popular_menu_items.dart';
import '../../features/menu/domain/usecases/process_menu_link.dart';
import '../../features/menu/domain/usecases/search_menu_items.dart';

import '../../features/menu/presentation/blocs/menu_bloc.dart';
import '../../features/menu/presentation/blocs/item_detail/item_detail_bloc.dart';

final sl = GetIt.instance;

Future<void> initMenu() async {
  // Cache
  sl.registerLazySingleton(() => MenuCacheService());

  // Firestore Queries
  sl.registerLazySingleton(() => MenuFirestoreQueries(sl()));

  // Remote Data Source
  sl.registerLazySingleton<MenuRemoteDataSource>(
    () => MenuRemoteDataSourceImpl(firestore: sl(), cache: sl()),
  );

  // Repository
  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(remoteDataSource: sl(), ocrRemoteDataSource: sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => GetMenuItemsByRestaurant(sl()));
  sl.registerLazySingleton(() => GetMenuItemsByCategory(sl()));
  sl.registerLazySingleton(() => GetPopularMenuItems(sl()));
  sl.registerLazySingleton(() => SearchMenuItems(sl()));
  sl.registerLazySingleton(() => GetMenuItemById(sl()));
  sl.registerLazySingleton(() => AddMenuPhoto(sl(), sl()));
  sl.registerLazySingleton(() => AddMenuUrl(sl()));
  sl.registerLazySingleton(() => ProcessMenuLink(sl()));

  // MenuBloc
  sl.registerFactory(
    () => MenuBloc(
      getMenuItemsByRestaurant: sl(),
      searchMenuItems: sl(),
      getPopularMenuItems: sl(),
      getMenuItemsByCategory: sl(),
      addMenuPhoto: sl(),
      addMenuUrl: sl(),
      processMenuLinkUseCase: sl(),
    ),
  );

  // ItemDetailBloc
  sl.registerFactory(
    () => ItemDetailBloc(getMenuItemById: sl(), getRestaurantById: sl()),
  );
}
