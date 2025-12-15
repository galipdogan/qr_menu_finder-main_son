import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_menu_finder/routing/home_routes.dart';
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
              Text('Sayfa bulunamadı: ${state.fullPath}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.home),
                child: const Text('Ana Sayfaya Dön'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  // static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  // static GoRouter get router => _router;

  // static final GoRouter _router = GoRouter(
  //   navigatorKey: _rootNavigatorKey,
  //   initialLocation: RouteNames.home,
  //   debugLogDiagnostics: true,
  //   redirect: _redirect,
  //   routes: [
  //     // Ana rotalar
  //     GoRoute(
  //       path: RouteNames.home,
  //       name: 'home',
  //       builder: (context, state) => BlocProvider(
  //         create: (context) => sl<RestaurantBloc>(),
  //         child: const HomePage(),
  //       ),
  //     ),

  //     // Auth rotaları
  //     GoRoute(
  //       path: RouteNames.login,
  //       name: 'login',
  //       builder: (context, state) => const LoginPage(),
  //     ),

  //     GoRoute(
  //       path: RouteNames.signup,
  //       name: 'signup',
  //       builder: (context, state) => const SignupPage(),
  //     ),

  //     // Restoran rotaları
  //     GoRoute(
  //       path: RouteNames.restaurantDetail,
  //       name: 'restaurant-detail',
  //       builder: (context, state) {
  //         final restaurantId = state.pathParameters['id']!;
  //         final Restaurant? initialRestaurant = state.extra is Restaurant
  //             ? state.extra as Restaurant
  //             : null;
  //         return BlocProvider(
  //           create: (context) => sl<RestaurantBloc>(),
  //           child: RestaurantDetailPage(
  //             restaurantId: restaurantId,
  //             initialRestaurant: initialRestaurant,
  //           ),
  //         );
  //       },
  //     ),

  //     GoRoute(
  //       path: RouteNames.restaurantSearch,
  //       name: 'restaurant-search',
  //       builder: (context, state) => const RestaurantSearchPage(),
  //     ),

  //     GoRoute(
  //       path: RouteNames.restaurantMap,
  //       name: 'restaurant-map',
  //       builder: (context, state) {
  //         List<Restaurant>? initialRestaurants;
  //         double? latitude;
  //         double? longitude;

  //         final extra = state.extra;
  //         if (extra is Map<String, dynamic>) {
  //           final data = extra;
  //           final maybeRestaurants = data['restaurants'];
  //           if (maybeRestaurants is List<Restaurant>) {
  //             initialRestaurants = maybeRestaurants;
  //           }
  //           final lat = data['latitude'];
  //           final lng = data['longitude'];
  //           if (lat is double) latitude = lat;
  //           if (lng is double) longitude = lng;
  //         }

  //         return BlocProvider(
  //           create: (context) => sl<RestaurantBloc>(),
  //           child: RestaurantMapPage(
  //             initialRestaurants: initialRestaurants,
  //             initialLatitude: latitude,
  //             initialLongitude: longitude,
  //           ),
  //         );
  //       },
  //     ),

  //     GoRoute(
  //       path: RouteNames.addRestaurant,
  //       name: 'add-restaurant',
  //       builder: (context, state) => const AddRestaurantPage(),
  //     ),

  //     // Menü rotaları
  //     GoRoute(
  //       path: RouteNames.addMenu,
  //       name: 'add-menu',
  //       builder: (context, state) {
  //         final restaurantId = state.pathParameters['restaurantId']!;
  //         final fromUrl = state.uri.queryParameters['fromUrl'] == 'true';
  //         return AddMenuPage(restaurantId: restaurantId, isUrl: fromUrl);
  //       },
  //     ),

  //     GoRoute(
  //       path: RouteNames.itemDetail,
  //       name: 'item-detail',
  //       builder: (context, state) {
  //         final restaurantId = state.pathParameters['restaurantId']!;
  //         final itemId = state.pathParameters['id']!;
  //         return ItemDetailPage(restaurantId: restaurantId, itemId: itemId);
  //       },
  //     ),

  //     // OCR rotası
  //     GoRoute(
  //       path: RouteNames.ocrVerification,
  //       name: 'ocr-verification',
  //       builder: (context, state) {
  //         final restaurantId = state.pathParameters['restaurantId']!;
  //         final imagePath = state.uri.queryParameters['imagePath'] ?? '';
  //         return OcrVerificationPage(
  //           restaurantId: restaurantId,
  //           imagePath: imagePath,
  //         );
  //       },
  //     ),

  //     // QR Scanner
  //     GoRoute(
  //       path: RouteNames.qrScanner,
  //       name: 'qr-scanner',
  //       builder: (context, state) => const QRScannerPage(),
  //     ),

  //     // Arama - Modern Search Feature with BLoC
  //     GoRoute(
  //       path: RouteNames.search,
  //       name: 'search',
  //       builder: (context, state) {
  //         final initialQuery = state.uri.queryParameters['q'];
  //         return BlocProvider(
  //           create: (context) => sl<SearchBloc>(),
  //           child: SearchPage(initialQuery: initialQuery),
  //         );
  //       },
  //     ),

  //     // Profil rotaları
  //     GoRoute(
  //       path: RouteNames.profile,
  //       name: 'profile',
  //       builder: (context, state) {
  //         return BlocProvider(
  //           create: (context) => sl<ReviewBloc>(),
  //           child: const ProfilePage(),
  //         );
  //       },
  //     ),

  //     GoRoute(
  //       path: RouteNames.editProfile,
  //       name: 'edit-profile',
  //       builder: (context, state) {
  //         final authState = context.read<AuthBloc>().state;
  //         if (authState is AuthAuthenticated) {
  //           return BlocProvider(
  //             create: (context) => sl<ProfileBloc>(),
  //             child: EditProfilePage(user: authState.user),
  //           );
  //         }
  //         // Eğer kullanıcı giriş yapmamışsa login'e yönlendir
  //         return const LoginPage();
  //       },
  //     ),

  //     GoRoute(
  //       path: RouteNames.favorites,
  //       name: 'favorites',
  //       builder: (context, state) => BlocProvider(
  //         create: (context) => sl<FavoritesBloc>(),
  //         child: const FavoritesPage(),
  //       ),
  //     ),

  //     GoRoute(
  //       path: RouteNames.history,
  //       name: 'history',
  //       builder: (context, state) => BlocProvider(
  //         create: (context) => sl<HistoryBloc>(),
  //         child: const HistoryPage(),
  //       ),
  //     ),

  //     GoRoute(
  //       path: RouteNames.settings,
  //       name: 'settings',
  //       builder: (context, state) {
  //         final settingType = state.uri.queryParameters['type'] ?? 'general';
  //         return SettingsPage(settingType: settingType);
  //       },
  //     ),

  //     // Owner panel
  //     GoRoute(
  //       path: RouteNames.ownerPanel,
  //       name: 'owner-panel',
  //       builder: (context, state) => BlocProvider(
  //         create: (context) => sl<OwnerPanelBloc>(),
  //         child: const OwnerPanelPage(),
  //       ),
  //     ),

  //     // Yorumlar
  //     GoRoute(
  //       path: RouteNames.comments,
  //       name: 'comments',
  //       builder: (context, state) {
  //         final restaurantId = state.pathParameters['restaurantId']!;
  //         return CommentsPage(restaurantId: restaurantId);
  //       },
  //     ),

  //     // Debug Search Test (only in debug mode)
  //     // Removed GoRoute definition for non-existent DebugSearchTest class.
  //   ],
  //   errorBuilder: (context, state) => Scaffold(
  //     body: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           const Icon(Icons.error, size: 64, color: Colors.red),
  //           const SizedBox(height: 16),
  //           Text('Sayfa bulunamadı: ${state.fullPath}'),
  //           const SizedBox(height: 16),
  //           ElevatedButton(
  //             onPressed: () => context.go(RouteNames.home),
  //             child: const Text('Ana Sayfaya Dön'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   ),
  // );

  // static String? _redirect(BuildContext context, GoRouterState state) {
  //   final authState = context.read<AuthBloc>().state;
  //   if (authState is AuthChecking) {
  //     return null;
  //   }
  //   final isLoggedIn = authState is AuthAuthenticated;

  //   // Giriş gerektiren sayfalar
  //   final protectedRoutes = [
  //     RouteNames.addRestaurant,
  //     RouteNames.addMenu,
  //     RouteNames.profile,
  //     RouteNames.editProfile,
  //     RouteNames.ownerPanel,
  //     RouteNames.favorites,
  //     RouteNames.history,
  //   ];

  //   final isProtectedRoute = protectedRoutes.any(
  //     (route) => state.fullPath?.startsWith(route) ?? false,
  //   );

  //   // Korumalı sayfaya giriş yapmadan erişmeye çalışıyorsa
  //   if (isProtectedRoute && !isLoggedIn) {
  //     return RouteNames.login;
  //   }

  //   // Giriş yapmış kullanıcı login sayfasına gitmeye çalışıyorsa
  //   if (isLoggedIn && state.fullPath == RouteNames.login) {
  //     return RouteNames.home;
  //   }

  //   return null; // Redirect yok
  // }
//}
