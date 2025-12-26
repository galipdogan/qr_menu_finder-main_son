import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

/// Use case for getting a user's review for a specific restaurant
/// Useful for checking if user already reviewed a restaurant
class GetUserReviewForRestaurant implements UseCase<Review?, GetUserReviewForRestaurantParams> {
  final ReviewRepository repository;

  GetUserReviewForRestaurant(this.repository);

  @override
  Future<Either<Failure, Review?>> call(GetUserReviewForRestaurantParams params) async {
    return await repository.getUserReviewForRestaurant(
      params.userId,
      params.restaurantId,
    );
  }
}

/// Parameters for getting user's review for a restaurant
class GetUserReviewForRestaurantParams extends Equatable {
  final String userId;
  final String restaurantId;

  const GetUserReviewForRestaurantParams({
    required this.userId,
    required this.restaurantId,
  });

  @override
  List<Object> get props => [userId, restaurantId];
}
