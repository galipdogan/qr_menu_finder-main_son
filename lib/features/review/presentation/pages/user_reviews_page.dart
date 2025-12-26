import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/error_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/presentation/blocs/auth_state.dart';
import '../blocs/review_bloc.dart';
import '../widgets/review_card.dart';
import '../widgets/edit_review_dialog.dart';

class UserReviewsPage extends StatefulWidget {
  const UserReviewsPage({super.key, required String restaurantId});

  @override
  State<UserReviewsPage> createState() => _UserReviewsPageState();
}

class _UserReviewsPageState extends State<UserReviewsPage> {
  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ReviewBloc>().add(LoadUserReviews(authState.user.id));
    }
  }

  Future<void> _deleteReview(String reviewId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yorumu Sil'),
        content: const Text(ErrorMessages.confirmDeleteReview),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(ErrorMessages.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirm == true) {
      context.read<ReviewBloc>().add(DeleteUserReview(reviewId));
    }
  }

  Future<void> _editReview(
    String reviewId,
    String currentText,
    double currentRating,
  ) async {
    if (!mounted) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditReviewDialog(
        initialText: currentText,
        initialRating: currentRating,
      ),
    );

    if (!mounted) return;

    if (result != null) {
      context.read<ReviewBloc>().add(
        UpdateUserReview(
          reviewId: reviewId,
          text: result['text'] as String,
          rating: result['rating'] as double,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ErrorMessages.reviewsTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state is ReviewError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is ReviewOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ReviewLoading) {
            return LoadingIndicator(message: ErrorMessages.reviewsLoading);
          }

          if (state is ReviewError) {
            return ErrorView(
              message: state.message,
              onRetry: _loadReviews,
            );
          }

          final reviews = state is ReviewLoaded
              ? state.reviews
              : state is ReviewOperationSuccess
              ? state.reviews
              : <dynamic>[];

          if (reviews.isEmpty) {
            return EmptyState(
              icon: Icons.rate_review,
              title: ErrorMessages.reviewsEmptyTitle,
              subtitle: ErrorMessages.reviewsEmptySubtitle,
              action: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(ErrorMessages.goBack),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadReviews(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final review = reviews[index];
                return ReviewCard(
                  review: review,
                  onEdit: () =>
                      _editReview(review.id, review.text, review.rating),
                  onDelete: () => _deleteReview(review.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
