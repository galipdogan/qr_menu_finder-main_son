import 'package:dartz/dartz.dart';
import '../../../../core/error/error.dart';
import '../../../../core/utils/repository_helper.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_data_source.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Review>>> getReviewsByUser(String userId) async {
    return RepositoryHelper.executeList(
      () => remoteDataSource.getReviewsByUser(userId),
      (model) => model as Review,
    );
  }

  @override
  Future<Either<Failure, List<Review>>> getReviewsByRestaurant(
    String restaurantId,
  ) async {
    return RepositoryHelper.executeList(
      () => remoteDataSource.getReviewsByRestaurant(restaurantId),
      (model) => model as Review,
    );
  }

  @override
  Future<Either<Failure, Review>> createReview({
    required String userId,
    required String restaurantId,
    required String text,
    required double rating,
  }) async {
    return RepositoryHelper.execute(
      () => remoteDataSource.createReview(
        userId: userId,
        restaurantId: restaurantId,
        text: text,
        rating: rating,
      ),
      (model) => model as Review,
    );
  }

  @override
  Future<Either<Failure, Review>> updateReview(
    String reviewId, {
    String? text,
    double? rating,
  }) async {
    return RepositoryHelper.execute(
      () => remoteDataSource.updateReview(reviewId, text: text, rating: rating),
      (model) => model as Review,
    );
  }

  @override
  Future<Either<Failure, void>> deleteReview(String reviewId) async {
    return RepositoryHelper.executeVoid(
      () => remoteDataSource.deleteReview(reviewId),
    );
  }

  @override
  Future<Either<Failure, Review?>> getUserReviewForRestaurant(
    String userId,
    String restaurantId,
  ) async {
    return RepositoryHelper.execute(
      () => remoteDataSource.getUserReviewForRestaurant(userId, restaurantId),
      (model) => model as Review?,
    );
  }
}
