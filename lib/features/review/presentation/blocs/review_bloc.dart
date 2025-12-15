import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/get_user_reviews.dart';
import '../../domain/usecases/delete_review.dart';
import '../../domain/usecases/update_review.dart';
import '../../../../core/utils/app_logger.dart';

// Events
abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserReviews extends ReviewEvent {
  final String userId;

  const LoadUserReviews(this.userId);

  @override
  List<Object?> get props => [userId];
}

class DeleteUserReview extends ReviewEvent {
  final String reviewId;

  const DeleteUserReview(this.reviewId);

  @override
  List<Object?> get props => [reviewId];
}

class UpdateUserReview extends ReviewEvent {
  final String reviewId;
  final String? text;
  final double? rating;

  const UpdateUserReview({
    required this.reviewId,
    this.text,
    this.rating,
  });

  @override
  List<Object?> get props => [reviewId, text, rating];
}

// States
abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewLoaded extends ReviewState {
  final List<Review> reviews;

  const ReviewLoaded(this.reviews);

  @override
  List<Object?> get props => [reviews];
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReviewOperationSuccess extends ReviewState {
  final String message;
  final List<Review> reviews;

  const ReviewOperationSuccess({
    required this.message,
    required this.reviews,
  });

  @override
  List<Object?> get props => [message, reviews];
}

// Bloc
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final GetUserReviews getUserReviews;
  final DeleteReview deleteReview;
  final UpdateReview updateReview;

  ReviewBloc({
    required this.getUserReviews,
    required this.deleteReview,
    required this.updateReview,
  }) : super(ReviewInitial()) {
    on<LoadUserReviews>(_onLoadUserReviews);
    on<DeleteUserReview>(_onDeleteUserReview);
    on<UpdateUserReview>(_onUpdateUserReview);
  }

  Future<void> _onLoadUserReviews(
    LoadUserReviews event,
    Emitter<ReviewState> emit,
  ) async {
    AppLogger.i('ReviewBloc: Loading reviews for user ${event.userId}');
    emit(ReviewLoading());
    final result = await getUserReviews(GetUserReviewsParams(userId: event.userId));
    result.fold(
      (failure) {
        AppLogger.e('ReviewBloc: Failed to load reviews', error: failure.message);
        emit(ReviewError('Yorumlar yüklenirken hata oluştu: ${failure.message}'));
      },
      (reviews) {
        AppLogger.i('ReviewBloc: Loaded ${reviews.length} reviews');
        emit(ReviewLoaded(reviews));
      },
    );
  }

  Future<void> _onDeleteUserReview(
    DeleteUserReview event,
    Emitter<ReviewState> emit,
  ) async {
    if (state is ReviewLoaded) {
      final currentReviews = (state as ReviewLoaded).reviews;
      AppLogger.i('ReviewBloc: Deleting review ${event.reviewId}');
      try {
        await deleteReview(DeleteReviewParams(reviewId: event.reviewId));
        final updatedReviews = currentReviews
            .where((review) => review.id != event.reviewId)
            .toList();
        AppLogger.i('ReviewBloc: Review deleted successfully');
        emit(ReviewOperationSuccess(
          message: 'Yorum başarıyla silindi',
          reviews: updatedReviews,
        ));
      } catch (e) {
        AppLogger.e('ReviewBloc: Failed to delete review', error: e);
        emit(ReviewError('Yorum silinirken hata oluştu: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateUserReview(
    UpdateUserReview event,
    Emitter<ReviewState> emit,
  ) async {
    if (state is ReviewLoaded) {
      final currentReviews = (state as ReviewLoaded).reviews;
      AppLogger.i('ReviewBloc: Updating review ${event.reviewId}');
      if (event.rating != null) {
        AppLogger.i('New rating: ${event.rating}');
      }
      try {
        final result = await updateReview(UpdateReviewParams(
          reviewId: event.reviewId,
          text: event.text,
          rating: event.rating,
        ));

        result.fold(
          (failure) {
            AppLogger.e('ReviewBloc: Failed to update review', error: failure.message);
            emit(ReviewError('Yorum güncellenirken hata oluştu: ${failure.message}'));
          },
          (updatedReview) {
            final updatedReviews = currentReviews.map((review) {
              return review.id == updatedReview.id ? updatedReview : review;
            }).toList();

            AppLogger.i('ReviewBloc: Review updated successfully');
            emit(ReviewOperationSuccess(
              message: 'Yorum başarıyla güncellendi',
              reviews: updatedReviews,
            ));
          },
        );
      } catch (e) {
        AppLogger.e('ReviewBloc: Failed to update review (unexpected error)', error: e);
        emit(ReviewError('Yorum güncellenirken beklenmedik bir hata oluştu: ${e.toString()}'));
      }
    }
  }
}