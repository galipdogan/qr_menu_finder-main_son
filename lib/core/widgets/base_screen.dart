import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Tüm ekranlar için temel widget
class BaseScreen extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool showAppBar;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? endDrawer;
  
  const BaseScreen({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showAppBar = true,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.appBar,
    this.drawer,
    this.endDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? (showAppBar && title != null 
        ? AppBar(
            title: Text(title!),
            actions: actions,
          )
        : null),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor ?? AppColors.background,
      drawer: drawer,
      endDrawer: endDrawer,
    );
  }
}