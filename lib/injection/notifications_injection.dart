import 'package:get_it/get_it.dart';

import '../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../features/notifications/data/repositories/notification_repository_impl.dart';
import '../features/notifications/domain/repositories/notification_repository.dart';
import '../features/notifications/domain/usecases/get_fcm_token.dart';
import '../features/notifications/domain/usecases/get_notification_settings.dart';
import '../features/notifications/domain/usecases/listen_to_foreground_messages.dart';
import '../features/notifications/domain/usecases/listen_to_opened_app_messages.dart';
import '../features/notifications/domain/usecases/listen_to_token_refresh.dart';
import '../features/notifications/domain/usecases/remove_fcm_token_for_user.dart';
import '../features/notifications/domain/usecases/request_notification_permission.dart';
import '../features/notifications/domain/usecases/save_fcm_token_for_user.dart';
import '../features/notifications/presentation/blocs/notification_bloc.dart';

void injectNotifications(GetIt sl) {
  sl.registerFactory(
    () => NotificationBloc(
      requestNotificationPermission: sl(),
      getFCMToken: sl(),
      getNotificationSettings: sl(),
      listenToForegroundMessages: sl(),
      listenToOpenedAppMessages: sl(),
      listenToTokenRefresh: sl(),
      saveFCMTokenForUser: sl(),
      removeFCMTokenForUser: sl(),
    ),
  );

  sl.registerLazySingleton(() => RequestNotificationPermission(sl()));
  sl.registerLazySingleton(() => GetFCMToken(sl()));
  sl.registerLazySingleton(() => GetNotificationSettings(sl()));
  sl.registerLazySingleton(() => ListenToForegroundMessages(sl()));
  sl.registerLazySingleton(() => ListenToOpenedAppMessages(sl()));
  sl.registerLazySingleton(() => ListenToTokenRefresh(sl()));
  sl.registerLazySingleton(() => SaveFCMTokenForUser(sl()));
  sl.registerLazySingleton(() => RemoveFCMTokenForUser(sl()));

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => FirebaseNotificationDataSourceImpl(
      firebaseMessaging: sl(),
      firestore: sl(),
    ),
  );
}
