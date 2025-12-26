import 'package:get_it/get_it.dart';

import '../features/favorites/data/datasources/favorites_remote_data_source.dart';
import '../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../features/favorites/domain/repositories/favorites_repository.dart';
import '../features/favorites/domain/usecases/add_favorite.dart';
import '../features/favorites/domain/usecases/get_user_favorites.dart';
import '../features/favorites/domain/usecases/remove_favorite.dart';
import '../features/favorites/domain/usecases/toggle_favorite.dart';
import '../features/favorites/presentation/blocs/favorites_bloc.dart';

void injectFavorites(GetIt sl) {
  sl.registerFactory(
    () => FavoritesBloc(
      getUserFavorites: sl(),
      addFavorite: sl(),
      removeFavorite: sl(),
      toggleFavorite: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetUserFavorites(sl()));
  sl.registerLazySingleton(() => AddFavorite(sl()));
  sl.registerLazySingleton(() => RemoveFavorite(sl()));
  sl.registerLazySingleton(() => ToggleFavorite(sl()));

  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<FavoritesRemoteDataSource>(
    () => FavoritesRemoteDataSourceImpl(firestore: sl()),
  );
}
