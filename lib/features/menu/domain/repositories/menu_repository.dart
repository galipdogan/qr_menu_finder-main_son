import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/menu_item.dart';

/// Abstract menu repository for clean architecture
abstract class MenuRepository {
  /// Get menu items by restaurant ID
  Future<Either<Failure, List<MenuItem>>> getMenuItemsByRestaurantId({
    required String restaurantId,
    String? category,
    int limit = 50,
  });

  /// Get menu item by ID
  Future<Either<Failure, MenuItem>> getMenuItemById(String id);

  /// Search menu items
  Future<Either<Failure, List<MenuItem>>> searchMenuItems({
    required String query,
    String? restaurantId,
    String? category,
    int limit = 20,
  });

  /// Create new menu item
  Future<Either<Failure, MenuItem>> createMenuItem(MenuItem menuItem);

  /// Update menu item
  Future<Either<Failure, MenuItem>> updateMenuItem(MenuItem menuItem);

  /// Delete menu item
  Future<Either<Failure, void>> deleteMenuItem(String id);

  /// Get popular menu items
  Future<Either<Failure, List<MenuItem>>> getPopularMenuItems({int limit = 10});

  /// Get menu items by category
  Future<Either<Failure, List<MenuItem>>> getMenuItemsByCategory({
    required String category,
    int limit = 20,
  });

  /// Get menu items by contributor
  Future<Either<Failure, List<MenuItem>>> getMenuItemsByContributor({
    required String contributorId,
    int limit = 20,
  });

  /// Add a menu link by URL (photo or external url)
  Future<Either<Failure, void>> addMenuUrl({
    required String restaurantId,
    required String url,
    required String type,
  });

  /// Add a menu photo by URL and attach it to the restaurant
  Future<Either<Failure, void>> addMenuPhoto({
    required String restaurantId,
    required String photoUrl,
  });

  /// Process a menu link
  Future<void> processMenuLink(String linkItemId);
}
