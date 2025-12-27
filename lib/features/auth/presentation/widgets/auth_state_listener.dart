import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../routing/route_names.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';

/// Reusable BlocListener for authentication state changes
/// 
/// Handles navigation and snackbar messages for auth events
class AuthStateListener extends StatelessWidget {
  final Widget child;
  final String? successMessage;
  final String? successRoute;
  final bool showUnauthenticatedMessage;

  const AuthStateListener({
    super.key,
    required this.child,
    this.successMessage,
    this.successRoute,
    this.showUnauthenticatedMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate to success route
          if (successRoute != null) {
            context.go(successRoute!);
          } else {
            context.go(RouteNames.home);
          }
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage ?? 'İşlem başarılı!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        } else if (state is AuthUnauthenticated && showUnauthenticatedMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.reason ?? 'Oturum kapatıldı'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      listenWhen: (previous, current) =>
          current is AuthError ||
          current is AuthAuthenticated ||
          (current is AuthUnauthenticated && showUnauthenticatedMessage),
      child: child,
    );
  }
}
