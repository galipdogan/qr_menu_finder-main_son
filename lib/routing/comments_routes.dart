import 'package:go_router/go_router.dart';
import 'package:qr_menu_finder/features/review/presentation/pages/user_reviews_page.dart';


import 'route_names.dart';

final List<GoRoute> commentsRoutes = [
  GoRoute(
    path: RouteNames.comments,
    builder: (context, state) {
      final restaurantId = state.pathParameters['restaurantId']!;
      return UserReviewsPage(restaurantId: restaurantId);
    },
  ),
];
