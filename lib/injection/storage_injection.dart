import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import '../features/storage/data/datasources/storage_remote_data_source.dart';
import '../features/storage/data/repositories/storage_repository_impl.dart';
import '../features/storage/domain/repositories/storage_repository.dart';
import '../features/storage/domain/usecases/delete_file.dart';
import '../features/storage/domain/usecases/upload_file.dart';

void injectStorage(GetIt sl) {
  sl.registerLazySingleton(() => UploadFile(sl()));
  sl.registerLazySingleton(() => DeleteFile(sl()));

  sl.registerLazySingleton<StorageRepository>(
    () => StorageRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<StorageRemoteDataSource>(
    () => FirebaseStorageDataSourceImpl(firebaseStorage: sl<FirebaseStorage>()),
  );
}
