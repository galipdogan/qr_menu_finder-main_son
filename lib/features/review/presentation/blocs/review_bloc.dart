import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/error_messages.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/get_user_reviews.dart';
import '../../domain/usecases/delete_review.dart';
import '../../domain/usecases/update_review.dart';
import '../../domain/usecases/create_review.dart';
import '../../domain/usecases/get_restaurant_reviews.dart';
import '../../domain/usecases/get_user_review_for_restaurant.dart';
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

class LoadRestaurantReviews extends ReviewEvent {
  final String restaurantId;

  const LoadRestaurantReviews(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

class CheckUserReviewForRestaurant extends ReviewEvent {
  final String userId;
  final String restaurantId;

  const CheckUserReviewForRestaurant({
    required this.userId,
    required this.restaurantId,
  });

  @override
  List<Object?> get props => [userId, restaurantId];
}

class CreateUserReview extends ReviewEvent {
  final String userId;
  final String restaurantId;
  final String text;
  final double rating;

  const CreateUserReview({
    required this.userId,
    required this.restaurantId,
    required this.text,
    required this.rating,
  });

  @override
  List<Object?> get props => [userId, restaurantId, text, rating];
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

class UserReviewForRestaurantLoaded extends ReviewState {
  final Review? review;

  const UserReviewForRestaurantLoaded(this.review);

  @override
  List<Object?> get props => [review];
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

class ReviewCreated extends ReviewState {
  final Review review;
  final String message;

  const ReviewCreated({
    required this.review,
    required this.message,
  });

  @override
  List<Object?> get props => [review, message];
}

// Bloc
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final GetUserReviews getUserReviews;
  final DeleteReview deleteReview;
  final UpdateReview updateReview;
  final CreateReview createReview;
  final GetRestaurantReviews getRestaurantReviews;
  final GetUserReviewForRestaurant getUserReviewForRestaurant;

  ReviewBloc({
    required this.getUserReviews,
    required this.deleteReview,
    required this.updateReview,
    required this.createReview,
    required this.getRestaurantReviews,
    required this.getUserReviewForRestaurant,
  }) : super(ReviewInitial()) {
    on<LoadUserReviews>(_onLoadUserReviews);
    on<LoadRestaurantReviews>(_onLoadRestaurantReviews);
    on<CheckUserReviewForRestaurant>(_onCheckUserReviewForRestaurant);
    on<CreateUserReview>(_onCreateUserReview);
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
        emit(ReviewError('${ErrorMessages.reviewLoadFailedPrefix} ${failure.message}'));
      },
      (reviews) {
        AppLogger.i('ReviewBloc: Loaded ${reviews.length} reviews');
        emit(ReviewLoaded(reviews));
      },
    );
  }

  Future<void> _onLoadRestaurantReviews(
    LoadRestaurantReviews event,
    Emitter<ReviewState> emit,
  ) async {
    AppLogger.i('ReviewBloc: Loading reviews for restaurant ${event.restaurantId}');
    emit(ReviewLoading());
    final result = await getRestaurantReviews(
      GetRestaurantReviewsParams(restaurantId: event.restaurantId),
    );
    result.fold(
      (failure) {
        AppLogger.e('ReviewBloc: Failed to load restaurant reviews', error: failure.message);
        emit(ReviewError('${ErrorMessages.reviewLoadFailedPrefix} ${failure.message}'));
      },
      (reviews) {
        AppLogger.i('ReviewBloc: Loaded ${reviews.length} restaurant reviews');
        emit(ReviewLoaded(reviews));
      },
    );
  }

  Future<void> _onCheckUserReviewForRestaurant(
    CheckUserReviewForRestaurant event,
    Emitter<ReviewState> emit,
  ) async {
    AppLogger.i('ReviewBloc: Checking user review for restaurant');
    emit(ReviewLoading());
    final result = await getUserReviewForRestaurant(
      GetUserReviewForRestaurantParams(
        userId: event.userId,
        restaurantId: event.restaurantId,
      ),
    );
    result.fold(
      (failure) {
        AppLogger.e('ReviewBloc: Failed to check user review', error: failure.message);
        emit(ReviewError('${ErrorMessages.reviewLoadFailedPrefix} ${failure.message}'));
      },
      (review) {
        AppLogger.i('ReviewBloc: User review check complete');
        emit(UserReviewForRestaurantLoaded(review));
      },
    );
  }

  Future<void> _onCreateUserReview(
    CreateUserReview event,
    Emitter<ReviewState> emit,
  ) async {
    AppLogger.i('ReviewBloc: Creating review for restaurant ${event.restaurantId}');
    emit(ReviewLoading());
    final result = await createReview(
      CreateReviewParams(
        userId: event.userId,
        restaurantId: event.restaurantId,
        text: event.text,
        rating: event.rating,
      ),
    );
    result.fold(
      (failure) {
        AppLogger.e('ReviewBloc: Failed to create review', error: failure.message);
        emit(ReviewError('Failed to create review: ${failure.message}'));
      },
      (review) {
        AppLogger.i('ReviewBloc: Review created successfully');
        emit(ReviewCreated(
          review: review,
          message: 'Review created successfully',
        ));
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
          message: ErrorMessages.reviewDeleteSuccess,
          reviews: updatedReviews,
        ));
      } catch (e) {
        AppLogger.e('ReviewBloc: Failed to delete review', error: e);
        emit(ReviewError('${ErrorMessages.reviewDeleteFailedPrefix} ${e.toString()}'));
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
            emit(ReviewError('${ErrorMessages.reviewUpdateFailedPrefix} ${failure.message}'));
          },
          (updatedReview) {
            final updatedReviews = currentReviews.map((review) {
              return review.id == updatedReview.id ? updatedReview : review;
            }).toList();

            AppLogger.i('ReviewBloc: Review updated successfully');
            emit(ReviewOperationSuccess(
              message: ErrorMessages.reviewUpdateSuccess,
              reviews: updatedReviews,
            ));
          },
        );
      } catch (e) {
        AppLogger.e('ReviewBloc: Failed to update review (unexpected error)', error: e);
        emit(ReviewError('${ErrorMessages.reviewUpdateUnexpectedFailedPrefix} ${e.toString()}'));
      }
    }
  }
}