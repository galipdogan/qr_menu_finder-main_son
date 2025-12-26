import 'package:get_it/get_it.dart';

import '../features/review/data/datasources/review_remote_data_source.dart';
import '../features/review/data/repositories/review_repository_impl.dart';
import '../features/review/domain/repositories/review_repository.dart';
import '../features/review/domain/usecases/create_review.dart';
import '../features/review/domain/usecases/delete_review.dart';
import '../features/review/domain/usecases/get_restaurant_reviews.dart';
import '../features/review/domain/usecases/get_user_review_for_restaurant.dart';
import '../features/review/domain/usecases/get_user_reviews.dart';
import '../features/review/domain/usecases/update_review.dart';
import '../features/review/presentation/blocs/review_bloc.dart';

void injectReview(GetIt sl) {
  sl.registerFactory(
    () => ReviewBloc(
      getUserReviews: sl(),
      deleteReview: sl(),
      updateReview: sl(),
      createReview: sl(),
      getRestaurantReviews: sl(),
      getUserReviewForRestaurant: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetUserReviews(sl()));
  sl.registerLazySingleton(() => DeleteReview(sl()));
  sl.registerLazySingleton(() => UpdateReview(sl()));
  sl.registerLazySingleton(() => CreateReview(sl()));
  sl.registerLazySingleton(() => GetRestaurantReviews(sl()));
  sl.registerLazySingleton(() => GetUserReviewForRestaurant(sl()));

  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(firestore: sl()),
  );
}
