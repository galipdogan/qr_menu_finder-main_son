import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_menu_finder/features/restaurant/presentation/blocs/restaurant_bloc.dart';
import 'package:qr_menu_finder/injection_container.dart' as di;
import 'route_names.dart';
import '../features/restaurant/domain/entities/restaurant.dart';
import '../features/restaurant/presentation/pages/restaurant_detail_page.dart';
import '../features/restaurant/presentation/pages/restaurant_search_page.dart';
import '../features/restaurant/presentation/pages/restaurant_map_page.dart';
import '../features/restaurant/presentation/pages/add_restaurant_page.dart';

/// Restaurant related routes
final List<GoRoute> restaurantRoutes = [
  GoRoute(
    path: RouteNames.restaurantDetail, // /restaurant/:id
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      final initialRestaurant = state.extra as Restaurant?;
      
      return BlocProvider(
        create: (_) => di.sl<RestaurantBloc>(),
        child: RestaurantDetailPage(
          restaurantId: id,
          initialRestaurant: initialRestaurant,
        ),
      );
    },
  ),

  GoRoute(
    path: RouteNames.restaurantSearch,
    builder: (context, state) => const RestaurantSearchPage(),
  ),
  GoRoute(
    path: RouteNames.restaurantMap,
    builder: (context, state) => const RestaurantMapPage(),
  ),
  GoRoute(
    path: RouteNames.addRestaurant,
    builder: (context, state) => const AddRestaurantPage(),
  ),
];
