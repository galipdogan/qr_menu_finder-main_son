import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/theme.dart';

/// Custom AppBar with back and home buttons
/// Shows back button if there's a previous route in the navigation stack
/// Always shows home button (unless already on home screen)
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showHomeButton;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showHomeButton = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final currentRoute = GoRouterState.of(context).uri.path;
    final isHomePage = currentRoute == '/';

    // Build actions list
    final List<Widget> appBarActions = [];

    // Add custom actions first
    if (actions != null) {
      appBarActions.addAll(actions!);
    }

    // Add home button if not on home page
    if (showHomeButton && !isHomePage) {
      appBarActions.add(
        IconButton(
          icon: const Icon(Icons.home),
          tooltip: 'Ana Sayfa',
          onPressed: () {
            context.go('/');
          },
        ),
      );
    }

    return AppBar(
      title: Text(title),
      backgroundColor: backgroundColor ?? ThemeProvider.primary(context),
      foregroundColor: foregroundColor ?? ThemeProvider.onPrimary(context),
      leading: (showBackButton && canPop)
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Geri',
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      actions: appBarActions.isNotEmpty ? appBarActions : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}