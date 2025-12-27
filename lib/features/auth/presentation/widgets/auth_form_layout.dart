import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// Reusable layout wrapper for authentication pages
/// 
/// Provides consistent structure: logo, title, form content, and footer
class AuthFormLayout extends StatelessWidget {
  final String title;
  final Widget formContent;
  final Widget? footer;
  final Color? logoColor;

  const AuthFormLayout({
    super.key,
    required this.title,
    required this.formContent,
    this.footer,
    this.logoColor,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // Logo
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: logoColor ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Form Content
            formContent,
            
            // Footer (optional)
            if (footer != null) ...[
              const SizedBox(height: 16),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}
