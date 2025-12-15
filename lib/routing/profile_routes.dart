import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_menu_finder/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:qr_menu_finder/features/auth/presentation/blocs/auth_state.dart';
import 'package:qr_menu_finder/features/auth/presentation/pages/login_page.dart';
import 'package:qr_menu_finder/features/favorites/presentation/pages/favorites_page.dart';
import 'package:qr_menu_finder/features/history/presentation/pages/history_page.dart';
import 'package:qr_menu_finder/features/profile/presentation/blocs/profile_bloc.dart';
import 'package:qr_menu_finder/features/settings/presentation/pages/settings_page.dart';
import '../injection_container.dart';
import 'route_names.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/profile/presentation/pages/edit_profile_page.dart';

/// Profile related routes
final List<GoRoute> profileRoutes = [
  GoRoute(
    path: RouteNames.profile,
    builder: (context, state) => const ProfilePage(),
  ),
  GoRoute(
    path: RouteNames.editProfile,
    name: 'edit-profile',
    builder: (context, state) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        return BlocProvider(
          create: (context) => sl<ProfileBloc>(),
          child: EditProfilePage(
            user: authState.user,
          ), // ✅ user parametresi eklendi
        );
      }
      // Eğer kullanıcı giriş yapmamışsa login sayfasına yönlendir
      return const LoginPage();
    },
  ),

  GoRoute(
    path: RouteNames.favorites,
    builder: (context, state) => const FavoritesPage(),
  ),
  GoRoute(
    path: RouteNames.history,
    builder: (context, state) => const HistoryPage(),
  ),
  GoRoute(
    path: RouteNames.settings,
    builder: (context, state) => const SettingsPage(),
  ),
];
