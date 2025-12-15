import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_constants.dart';

/// Shimmer loading widgets for better UX
class ShimmerLoading {
  /// Restaurant card shimmer
  static Widget restaurantCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultSpacing),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultSpacing),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerBox(width: 80, height: 80, radius: 8),
            const SizedBox(width: AppConstants.defaultSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(width: 100, height: 20, radius: 4),
                  const SizedBox(height: 8),
                  _shimmerBox(width: double.infinity, height: 16, radius: 4),
                  const SizedBox(height: 4),
                  _shimmerBox(width: double.infinity, height: 16, radius: 4),
                  const SizedBox(height: 8),
                  _shimmerBox(width: 150, height: 14, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Menu item card shimmer
  static Widget menuItemCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultSpacing),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultSpacing),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerBox(width: 60, height: 60, radius: 8),
            const SizedBox(width: AppConstants.defaultSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(width: double.infinity, height: 18, radius: 4),
                  const SizedBox(height: 8),
                  _shimmerBox(width: 120, height: 14, radius: 4),
                  const SizedBox(height: 8),
                  _shimmerBox(width: 80, height: 16, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// List shimmer
  static Widget list({int itemCount = 5, Widget Function()? itemBuilder}) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultSpacing),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return itemBuilder?.call() ?? restaurantCard();
      },
    );
  }

  /// Grid shimmer
  static Widget grid({int itemCount = 6}) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultSpacing),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppConstants.defaultSpacing,
        mainAxisSpacing: AppConstants.defaultSpacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerBox(width: double.infinity, height: 120, radius: 0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(width: double.infinity, height: 16, radius: 4),
                    const SizedBox(height: 8),
                    _shimmerBox(width: 100, height: 14, radius: 4),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Image shimmer
  static Widget image({
    required double width,
    required double height,
    double radius = 0,
  }) {
    return _shimmerBox(width: width, height: height, radius: radius);
  }

  /// Text shimmer
  static Widget text({
    required double width,
    double height = 16,
    double radius = 4,
  }) {
    return _shimmerBox(width: width, height: height, radius: radius);
  }

  /// Base shimmer box
  static Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 0,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
