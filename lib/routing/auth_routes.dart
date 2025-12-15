import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/signup_page.dart';

/// Authentication related routes
final List<GoRoute> authRoutes = [
  GoRoute(
    path: RouteNames.login,
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute(
    path: RouteNames.signup,
    builder: (context, state) => const SignupPage(),
  ),
];
