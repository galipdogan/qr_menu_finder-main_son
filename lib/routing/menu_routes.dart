import 'package:go_router/go_router.dart';
import 'package:qr_menu_finder/features/menu/presentation/blocs/menu_bloc.dart';
import 'package:qr_menu_finder/features/menu/presentation/pages/add_menu_page.dart';
import 'package:qr_menu_finder/injection_container.dart' as di;
import 'route_names.dart';
import '../features/menu/presentation/pages/item_detail_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/menu/presentation/pages/menu_page.dart';

final List<GoRoute> menuRoutes = [
  // ✅ Menü item detay (ItemDetailPage)
  GoRoute(
    path: RouteNames.menuItem, // /restaurant/:restaurantId/item/:id
    builder: (context, state) {
      final restaurantId = state.pathParameters['restaurantId']!;
      final itemId = state.pathParameters['id']!;
      return ItemDetailPage(restaurantId: restaurantId, itemId: itemId);
    },
  ),
  GoRoute(
    path: "/restaurant/:restaurantId/add-menu",
    builder: (context, state) {
      final restaurantId = state.pathParameters["restaurantId"]!;

      return BlocProvider<MenuBloc>(
        create: (_) => di.sl<MenuBloc>(),
        child: AddMenuPage(restaurantId: restaurantId),
      );
    },
  ),
  GoRoute(
    path: RouteNames.menu,
    builder: (context, state) {
      final restaurantId = state.pathParameters['restaurantId']!;
      return BlocProvider(
        create: (_) => di.sl<MenuBloc>(),
        child: MenuPage(restaurantId: restaurantId, restaurantName: null),
      );
    },
  ),
];
