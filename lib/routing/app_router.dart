import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_menu_finder/routing/home_routes.dart';
import 'package:qr_menu_finder/core/error/error_messages.dart';
import 'package:qr_menu_finder/routing/route_names.dart';
import 'auth_routes.dart';
import 'restaurant_routes.dart';
import 'menu_routes.dart';
import 'profile_routes.dart';
import 'owner_routes.dart';
import 'ocr_routes.dart';
import 'qr_routes.dart';
import 'search_routes.dart';
import 'comments_routes.dart';
import 'route_guards.dart'; // ✅ redirect için

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.home,
    debugLogDiagnostics: true,
    routes: [
      ...homeRoutes,
      ...authRoutes,
      ...restaurantRoutes,
      ...menuRoutes,
      ...profileRoutes,
      ...ownerRoutes,
      ...ocrRoutes,
      ...qrRoutes,
      ...searchRoutes,
      ...commentsRoutes,
    ],
    redirect: authGuard, // ✅ login kontrolü
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('${ErrorMessages.pageNotFoundPrefix} ${state.fullPath}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.home),
                child: const Text(ErrorMessages.goHome),
              ),
            ],
          ),
        ),
      );
    },
  );
}