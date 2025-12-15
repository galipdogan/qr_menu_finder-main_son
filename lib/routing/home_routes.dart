import 'package:go_router/go_router.dart';

import '../features/home/presentation/pages/home_page.dart';
import 'route_names.dart';

final homeRoutes = [
  GoRoute(path: RouteNames.home, builder: (context, state) => const HomePage()),
];
