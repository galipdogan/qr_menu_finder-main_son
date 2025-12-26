import 'package:get_it/get_it.dart';

import '../core/config/meilisearch_config.dart';
import '../features/search/data/services/meilisearch_sync_service.dart';
import '../features/search/data/datasources/meilisearch_remote_data_source.dart';
import '../features/search/data/datasources/search_remote_data_source.dart';
import '../features/search/data/repositories/hybrid_search_repository_impl.dart';
import '../features/search/domain/repositories/search_repository.dart';
import '../features/search/domain/usecases/get_search_suggestions.dart';
import '../features/search/domain/usecases/search_items.dart';
import '../features/search/presentation/blocs/search_bloc.dart';

void injectSearch(GetIt sl) {
  sl.registerFactory(
    () => SearchBloc(searchItems: sl(), getSearchSuggestions: sl()),
  );

  sl.registerLazySingleton(() => SearchItems(sl()));
  sl.registerLazySingleton(() => GetSearchSuggestions(sl()));

  sl.registerLazySingleton<SearchRepository>(
    () => HybridSearchRepositoryImpl(
      firestoreDataSource: sl(),
      meilisearchDataSource: MeiliSearchConfig.isEnabled ? sl() : null,
    ),
  );

  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(firestore: sl()),
  );

  if (MeiliSearchConfig.isEnabled) {
    sl.registerLazySingleton<MeiliSearchRemoteDataSource>(
      () => MeiliSearchRemoteDataSourceImpl(client: sl()),
    );

    sl.registerLazySingleton(
      () =>
          MeiliSearchSyncService(firestore: sl(), meilisearchDataSource: sl()),
    );
  }
}
