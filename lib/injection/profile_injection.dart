import 'package:get_it/get_it.dart';

import '../features/profile/data/datasources/profile_remote_data_source.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/profile/domain/usecases/get_user_profile.dart'
    as profile_uc;
import '../features/profile/domain/usecases/update_profile.dart';
import '../features/profile/presentation/blocs/profile_bloc.dart';

void injectProfile(GetIt sl) {
  sl.registerFactory(
    () => ProfileBloc(getUserProfile: sl(), updateProfile: sl()),
  );

  sl.registerLazySingleton(() => profile_uc.GetUserProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(firestore: sl()),
  );
}
