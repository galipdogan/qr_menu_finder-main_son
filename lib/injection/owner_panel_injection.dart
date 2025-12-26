import 'package:get_it/get_it.dart';

import '../features/owner_panel/data/datasources/owner_panel_remote_data_source.dart';
import '../features/owner_panel/data/repositories/owner_panel_repository_impl.dart';
import '../features/owner_panel/domain/repositories/owner_panel_repository.dart';
import '../features/owner_panel/domain/usecases/get_owner_restaurants.dart';
import '../features/owner_panel/domain/usecases/get_owner_stats.dart';
import '../features/owner_panel/domain/usecases/request_owner_upgrade.dart';
import '../features/owner_panel/presentation/blocs/owner_panel_bloc.dart';

void injectOwnerPanel(GetIt sl) {
  sl.registerFactory(
    () => OwnerPanelBloc(
      getOwnerStats: sl(),
      getOwnerRestaurants: sl(),
      requestOwnerUpgrade: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetOwnerStats(sl()));
  sl.registerLazySingleton(() => GetOwnerRestaurants(sl()));
  sl.registerLazySingleton(() => RequestOwnerUpgrade(sl()));

  sl.registerLazySingleton<OwnerPanelRepository>(
    () => OwnerPanelRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<OwnerPanelRemoteDataSource>(
    () => OwnerPanelRemoteDataSourceImpl(firestore: sl()),
  );
}
