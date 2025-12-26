import 'package:get_it/get_it.dart';
//import 'package:firebase_analytics/firebase_analytics.dart';

import '../features/analytics/data/datasources/analytics_remote_data_source.dart';
import '../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../features/analytics/domain/repositories/analytics_repository.dart';
import '../features/analytics/domain/usecases/initialize_analytics.dart';
import '../features/analytics/domain/usecases/log_analytics_event.dart';

void injectAnalytics(GetIt sl) {
  sl.registerLazySingleton(() => InitializeAnalytics(sl()));
  sl.registerLazySingleton(() => LogAnalyticsEvent(sl()));

  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AnalyticsRemoteDataSource>(
    () => FirebaseAnalyticsDataSourceImpl(firebaseAnalytics: sl()),
  );
}
