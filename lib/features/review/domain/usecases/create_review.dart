import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

/// Use case for creating a new review
class CreateReview implements UseCase<Review, CreateReviewParams> {
  final ReviewRepository repository;

  CreateReview(this.repository);

  @override
  Future<Either<Failure, Review>> call(CreateReviewParams params) async {
    // Validate rating
    if (params.rating < 1.0 || params.rating > 5.0) {
      return Left(ValidationFailure('Rating must be between 1.0 and 5.0'));
    }

    // Validate text
    if (params.text.trim().isEmpty) {
      return Left(ValidationFailure('Review text cannot be empty'));
    }

    return await repository.createReview(
      userId: params.userId,
      restaurantId: params.restaurantId,
      text: params.text,
      rating: params.rating,
    );
  }
}

/// Parameters for creating a review
class CreateReviewParams extends Equatable {
  final String userId;
  final String restaurantId;
  final String text;
  final double rating;

  const CreateReviewParams({
    required this.userId,
    required this.restaurantId,
    required this.text,
    required this.rating,
  });

  @override
  List<Object> get props => [userId, restaurantId, text, rating];
}
