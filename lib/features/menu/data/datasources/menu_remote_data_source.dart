import '../models/menu_item_model.dart';

/// Abstract menu remote data source
abstract class MenuRemoteDataSource {
  Future<List<MenuItemModel>> getMenuItemsByRestaurantId({
    required String restaurantId,
    String? category,
    int limit,
  });

  Future<MenuItemModel> getMenuItemById(String id);

  Future<List<MenuItemModel>> searchMenuItems({
    required String query,
    String? restaurantId,
    String? category,
    int limit,
  });

  Future<MenuItemModel> createMenuItem(MenuItemModel menuItem);

  Future<MenuItemModel> updateMenuItem(MenuItemModel menuItem);

  Future<void> deleteMenuItem(String id);

  Future<List<MenuItemModel>> getPopularMenuItems({int limit});

  Future<List<MenuItemModel>> getMenuItemsByCategory({
    required String category,
    int limit,
  });

  Future<List<MenuItemModel>> getMenuItemsByContributor({
    required String contributorId,
    int limit,
  });

  Future<void> addMenuLink({
    required String restaurantId,
    required String url,
    required String type,
  });

  Future<void> createOcrItem({
    required String restaurantId,
    required double price,
    required String? currency,
  });

  Future<void> markLinkAsProcessed(String linkItemId);
}
