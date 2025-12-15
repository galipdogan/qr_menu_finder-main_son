import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class GetUserReviews implements UseCase<List<Review>, GetUserReviewsParams> {
  final ReviewRepository repository;

  GetUserReviews(this.repository);

  @override
  Future<Either<Failure, List<Review>>> call(
    GetUserReviewsParams params,
  ) async {
    return await repository.getReviewsByUser(params.userId);
  }
}

class GetUserReviewsParams extends Equatable {
  final String userId;
  const GetUserReviewsParams({required this.userId});
  @override
  List<Object?> get props => [userId];
}
