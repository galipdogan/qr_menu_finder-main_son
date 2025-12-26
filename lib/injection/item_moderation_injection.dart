import 'package:get_it/get_it.dart';

import '../features/item_moderation/data/datasources/item_moderation_remote_data_source.dart';
import '../features/item_moderation/data/repositories/item_moderation_repository_impl.dart';
import '../features/item_moderation/domain/repositories/item_moderation_repository.dart';
import '../features/item_moderation/domain/usecases/approve_item_usecase.dart';
import '../features/item_moderation/domain/usecases/promote_to_live_usecase.dart';
import '../features/item_moderation/domain/usecases/reject_item_usecase.dart';
import '../features/item_moderation/domain/usecases/report_item_usecase.dart';
import '../features/item_moderation/presentation/blocs/item_moderation_bloc.dart';

void injectItemModeration(GetIt sl) {
  sl.registerFactory(
    () => ItemModerationBloc(
      promoteToLiveUseCase: sl(),
      approveItemUseCase: sl(),
      rejectItemUseCase: sl(),
      reportItemUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => PromoteToLiveUseCase(sl()));
  sl.registerLazySingleton(() => ApproveItemUseCase(sl()));
  sl.registerLazySingleton(() => RejectItemUseCase(sl()));
  sl.registerLazySingleton(() => ReportItemUseCase(sl()));

  sl.registerLazySingleton<ItemModerationRepository>(
    () => ItemModerationRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ItemModerationRemoteDataSource>(
    () => ItemModerationRemoteDataSourceImpl(firestore: sl(), auth: sl()),
  );
}
