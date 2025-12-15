import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_menu_finder/features/auth/presentation/blocs/auth_state.dart';
import '../features/auth/presentation/blocs/auth_bloc.dart';
import 'route_names.dart';

String? authGuard(BuildContext context, GoRouterState state) {
  final authState = context.read<AuthBloc>().state;

  final isLoggedIn = authState is AuthAuthenticated;

  final isGoingToLogin = state.fullPath == RouteNames.login;
  final isGoingToSignup = state.fullPath == RouteNames.signup;

  if (isLoggedIn && (isGoingToLogin || isGoingToSignup)) {
    return RouteNames.home;
  }

  final protectedRoutes = [
    RouteNames.addRestaurant,
    RouteNames.addMenu,
    RouteNames.profile,
    RouteNames.editProfile,
    RouteNames.ownerPanel,
    RouteNames.favorites,
    RouteNames.history,
  ];

  final isProtectedRoute = protectedRoutes.any(
    (route) => state.fullPath?.startsWith(route) ?? false,
  );

  if (!isLoggedIn && isProtectedRoute) {
    return RouteNames.login;
  }

  return null; // redirect yok
}
