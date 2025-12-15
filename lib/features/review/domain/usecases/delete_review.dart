import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/review_repository.dart';

class DeleteReview implements UseCase<void, DeleteReviewParams> {
  final ReviewRepository repository;

  DeleteReview(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteReviewParams params) async {
    return await repository.deleteReview(params.reviewId);
  }
}

class DeleteReviewParams extends Equatable {
  final String reviewId;
  const DeleteReviewParams({required this.reviewId});
  @override
  List<Object?> get props => [reviewId];
}
