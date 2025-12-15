import 'package:go_router/go_router.dart';
import 'package:qr_menu_finder/features/owner_panel/presentation/pages/owner_panel_page.dart';
import 'route_names.dart';

/// Owner related routes
final List<GoRoute> ownerRoutes = [
  GoRoute(
    path: RouteNames.ownerPanel,
    builder: (context, state) => const OwnerPanelPage(),
  ),
];
