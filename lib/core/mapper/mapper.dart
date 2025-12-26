import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/restaurant/data/models/restaurant_model.dart';
import '../../features/restaurant/domain/entities/restaurant.dart';
import '../../features/menu/data/models/menu_item_model.dart';
import '../../features/menu/domain/entities/menu_item.dart';
import '../../features/review/data/models/review_model.dart';
import '../../features/review/domain/entities/review.dart';
import 'mapper.auto_mappr.dart';

@AutoMappr([
  MapType<UserModel, User>(),
  MapType<User, UserModel>(),
  MapType<RestaurantModel, Restaurant>(),
  MapType<Restaurant, RestaurantModel>(
    fields: [
      Field('placeId', custom: Mappr.generatePlaceId),
      Field('geohash', custom: Mappr.generateGeohash),
    ],
  ),
  MapType<MenuItemModel, MenuItem>(),
  MapType<MenuItem, MenuItemModel>(),
  MapType<ReviewModel, Review>(),
  MapType<Review, ReviewModel>(),
])
class Mappr extends $Mappr {
  static String generatePlaceId(Restaurant restaurant) => restaurant.id;
  static String generateGeohash(Restaurant restaurant) => '';
}
