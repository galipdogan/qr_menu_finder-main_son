import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/review.dart';

abstract class ReviewRepository {
  Future<Either<Failure, List<Review>>> getReviewsByUser(String userId);
  Future<Either<Failure, List<Review>>> getReviewsByRestaurant(
    String restaurantId,
  );
  Future<Either<Failure, Review>> createReview({
    required String userId,
    required String restaurantId,
    required String text,
    required double rating,
  });
  Future<Either<Failure, Review>> updateReview(
    String reviewId, {
    String? text,
    double? rating,
  });
  Future<Either<Failure, void>> deleteReview(String reviewId);
  Future<Either<Failure, Review?>> getUserReviewForRestaurant(
    String userId,
    String restaurantId,
  );
}
