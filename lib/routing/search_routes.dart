import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../features/navigation/presentation/pages/main_navigation_page.dart';

final List<GoRoute> searchRoutes = [
  GoRoute(
    path: RouteNames.search,
    builder: (context, state) {
      // Navigate to MainNavigationPage with Search tab (index 1)
      return const MainNavigationPage(initialIndex: 1);
    },
  ),
];
