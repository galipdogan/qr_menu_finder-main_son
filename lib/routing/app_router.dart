import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import 'home_routes.dart';
import 'auth_routes.dart';
import 'search_routes.dart';
import 'profile_routes.dart';
import 'restaurant_routes.dart';
import 'menu_routes.dart';
import 'ocr_routes.dart';
import 'qr_routes.dart';
import 'comments_routes.dart';
import 'owner_routes.dart';

class AppRouter {
  // Navigator keys
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  
  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.home,
    debugLogDiagnostics: true,
    routes: [
      ...authRoutes,
      ...homeRoutes,
      ...searchRoutes,
      ...profileRoutes,
      ...restaurantRoutes,
      ...menuRoutes,
      ...ocrRoutes,
      ...qrRoutes,
      ...commentsRoutes,
      ...ownerRoutes,
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Sayfa bulunamadı: ${state.uri.path}'),
      ),
    ),
  );
}
