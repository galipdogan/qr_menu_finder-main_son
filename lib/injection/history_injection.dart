import 'package:get_it/get_it.dart';

import '../features/history/data/datasources/history_remote_data_source.dart';
import '../features/history/data/repositories/history_repository_impl.dart';
import '../features/history/domain/repositories/history_repository.dart';
import '../features/history/domain/usecases/clear_history.dart';
import '../features/history/domain/usecases/delete_history_entry.dart';
import '../features/history/domain/usecases/get_user_history.dart';
import '../features/history/domain/usecases/track_search.dart';
import '../features/history/presentation/blocs/history_bloc.dart';

void injectHistory(GetIt sl) {
  sl.registerFactory(
    () => HistoryBloc(
      getUserHistory: sl(),
      clearHistory: sl(),
      deleteHistoryEntry: sl(),
      trackSearch: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetUserHistory(sl()));
  sl.registerLazySingleton(() => ClearHistory(sl()));
  sl.registerLazySingleton(() => DeleteHistoryEntry(sl()));
  sl.registerLazySingleton(() => TrackSearch(sl()));

  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<HistoryRemoteDataSource>(
    () => HistoryRemoteDataSourceImpl(firestore: sl()),
  );
}
