import 'package:get_it/get_it.dart';

import '../features/auth/data/datasources/auth_local_data_source.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/get_current_user.dart';
import '../features/auth/domain/usecases/sign_in_with_email_password.dart';
import '../features/auth/domain/usecases/sign_out.dart';
import '../features/auth/domain/usecases/sign_up_with_email_password.dart';
import '../features/auth/presentation/blocs/auth_bloc.dart';

void injectAuth(GetIt sl) {
  sl.registerFactory(
    () => AuthBloc(
      getCurrentUser: sl(),
      signInWithEmailPassword: sl(),
      signUpWithEmailPassword: sl(),
      signOut: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => SignInWithEmailPassword(sl()));
  sl.registerLazySingleton(() => SignUpWithEmailPassword(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl(), mappr: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );
}
