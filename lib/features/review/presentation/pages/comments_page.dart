import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/review_bloc.dart';
import 'user_reviews_page.dart';
import '../../../../injection_container.dart';

/// Legacy wrapper for CommentsScreen - redirects to modern UserReviewsPage
class CommentsPage extends StatelessWidget {
  final String restaurantId;

  const CommentsPage({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    // Provide ReviewBloc and redirect to modern implementation
    return BlocProvider(
      create: (context) => sl<ReviewBloc>(),
      child: const UserReviewsPage(),
    );
  }
}
