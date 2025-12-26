import 'package:get_it/get_it.dart';

import '../features/price_comparison/data/datasources/price_comparison_remote_data_source.dart';
import '../features/price_comparison/data/repositories/price_comparison_repository_impl.dart';
import '../features/price_comparison/domain/repositories/price_comparison_repository.dart';
import '../features/price_comparison/domain/usecases/get_compared_prices.dart';
import '../features/price_comparison/presentation/blocs/price_comparison_bloc.dart';

void injectPriceComparison(GetIt sl) {
  sl.registerFactory(() => PriceComparisonBloc(getComparedPrices: sl()));

  sl.registerLazySingleton(() => GetComparedPrices(sl()));

  sl.registerLazySingleton<PriceComparisonRepository>(
    () => PriceComparisonRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<PriceComparisonRemoteDataSource>(
    () => PriceComparisonRemoteDataSourceImpl(firestore: sl()),
  );
}
