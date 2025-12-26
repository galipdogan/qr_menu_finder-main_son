import 'package:flutter/material.dart';
import '../../../../core/error/error_messages.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/blocs/auth_event.dart';
import '../../../auth/presentation/blocs/auth_state.dart';

class UserMenuButton extends StatelessWidget {
  const UserMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return PopupMenuButton<String>(
          icon: Icon(
            authState is AuthAuthenticated
                ? Icons.account_circle
                : Icons.account_circle_outlined,
          ),
          onSelected: (value) {
            switch (value) {
              case 'profile':
                context.go(RouteNames.profile);
                break;
              case 'favorites':
                context.go(RouteNames.favorites);
                break;
              case 'history':
                context.go(RouteNames.history);
                break;
              case 'owner_panel':
                context.go(RouteNames.ownerPanel);
                break;
              case 'settings':
                context.go(RouteNames.settings);
                break;
              case 'login':
                context.go(RouteNames.login);
                break;
              case 'logout':
                context.read<AuthBloc>().add(AuthSignOutRequested());
                break;
            }
          },
          itemBuilder: (context) {
            if (authState is AuthAuthenticated) {
              final user = authState.user;
              return [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? 'Kullanıcı',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(user.email, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 8),
                      Text('Profil'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'favorites',
                  child: Row(
                    children: [
                      Icon(Icons.favorite),
                      SizedBox(width: 8),
                      Text('Favoriler'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'history',
                  child: Row(
                    children: [
                      Icon(Icons.history),
                      SizedBox(width: 8),
                      Text('Geçmiş'),
                    ],
                  ),
                ),
                if (user.role == UserRole.owner || user.role == UserRole.admin)
                  const PopupMenuItem(
                    value: 'owner_panel',
                    child: Row(
                      children: [
                        Icon(Icons.dashboard),
                        SizedBox(width: 8),
                        Text('İşletme Paneli'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('Ayarlar'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Çıkış Yap'),
                    ],
                  ),
                ),
              ];
            } else {
              return [
                const PopupMenuItem(
                  value: 'login',
                  child: Row(
                    children: [
                      Icon(Icons.login),
                      SizedBox(width: 8),
                      Text(ErrorMessages.login),
                    ],
                  ),
                ),
              ];
            }
          },
        );
      },
    );
  }
}
