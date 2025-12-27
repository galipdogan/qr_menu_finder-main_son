import 'package:go_router/go_router.dart';

import '../features/navigation/presentation/pages/main_navigation_page.dart';
import 'route_names.dart';

final homeRoutes = [
  GoRoute(
    path: RouteNames.home,
    builder: (context, state) => const MainNavigationPage(initialIndex: 0),
  ),
];
