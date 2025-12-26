import 'package:get_it/get_it.dart';

import '../core/theme/theme_bloc.dart';
import '../features/settings/data/datasources/settings_local_data_source.dart';
import '../features/settings/data/repositories/settings_repository_impl.dart';
import '../features/settings/domain/repositories/settings_repository.dart';
import '../features/settings/domain/usecases/get_language.dart';
import '../features/settings/domain/usecases/get_notifications_status.dart';
import '../features/settings/domain/usecases/get_theme_mode.dart';
import '../features/settings/domain/usecases/set_language.dart';
import '../features/settings/domain/usecases/set_notifications_status.dart';
import '../features/settings/domain/usecases/set_theme_mode.dart';
import '../features/settings/presentation/blocs/settings_bloc.dart';

void injectSettings(GetIt sl) {
  sl.registerFactory(
    () => SettingsBloc(
      getLanguage: sl(),
      setLanguage: sl(),
      getNotificationsStatus: sl(),
      setNotificationsStatus: sl(),
      getThemeMode: sl(),
      setThemeMode: sl(),
    ),
  );

  sl.registerFactory(() => ThemeBloc(getThemeMode: sl(), setThemeMode: sl()));

  sl.registerLazySingleton(() => GetLanguage(sl()));
  sl.registerLazySingleton(() => SetLanguage(sl()));
  sl.registerLazySingleton(() => GetNotificationsStatus(sl()));
  sl.registerLazySingleton(() => SetNotificationsStatus(sl()));
  sl.registerLazySingleton(() => GetThemeMode(sl()));
  sl.registerLazySingleton(() => SetThemeMode(sl()));

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(sharedPreferences: sl()),
  );
}
