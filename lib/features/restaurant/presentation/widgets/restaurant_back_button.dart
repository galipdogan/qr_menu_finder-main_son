import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../routing/route_names.dart';

class RestaurantBackButton extends StatelessWidget {
  const RestaurantBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Check if we can pop, otherwise go to home
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.home);
            }
          },
        ),
      ),
    );
  }
}
