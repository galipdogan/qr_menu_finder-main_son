import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

/// Use case for getting reviews for a specific restaurant
class GetRestaurantReviews implements UseCase<List<Review>, GetRestaurantReviewsParams> {
  final ReviewRepository repository;

  GetRestaurantReviews(this.repository);

  @override
  Future<Either<Failure, List<Review>>> call(GetRestaurantReviewsParams params) async {
    return await repository.getReviewsByRestaurant(params.restaurantId);
  }
}

/// Parameters for getting restaurant reviews
class GetRestaurantReviewsParams extends Equatable {
  final String restaurantId;

  const GetRestaurantReviewsParams({required this.restaurantId});

  @override
  List<Object> get props => [restaurantId];
}
