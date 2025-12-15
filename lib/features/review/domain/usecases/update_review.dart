import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class UpdateReview implements UseCase<Review, UpdateReviewParams> {
  final ReviewRepository repository;

  UpdateReview(this.repository);

  @override
  Future<Either<Failure, Review>> call(UpdateReviewParams params) async {
    return await repository.updateReview(
      params.reviewId,
      text: params.text,
      rating: params.rating,
    );
  }
}

class UpdateReviewParams extends Equatable {
  final String reviewId;
  final String? text;
  final double? rating;

  const UpdateReviewParams({required this.reviewId, this.text, this.rating});

  @override
  List<Object?> get props => [reviewId, text, rating];
}
