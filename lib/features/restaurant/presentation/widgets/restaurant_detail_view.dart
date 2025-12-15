import 'package:flutter/material.dart';
import '../../domain/entities/restaurant.dart';

// ✅ Alt widget importları
import 'restaurant_header.dart';
import 'restaurant_info_section.dart';
import 'restaurant_map_preview.dart';
import 'restaurant_actions.dart';
import 'restaurant_menu_placeholder.dart';
import 'restaurant_osm_footer.dart';
import 'restaurant_back_button.dart';
import 'restaurant_favorite_button.dart';
import 'restaurant_stale_indicator.dart';

class RestaurantDetailView extends StatelessWidget {
  final Restaurant restaurant;
  final bool isStale;

  const RestaurantDetailView({
    super.key,
    required this.restaurant,
    this.isStale = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            RestaurantHeader(restaurant: restaurant),

            // ✅ Expanded + ScrollView + Column çakışmasını çözen yapı
            Expanded(
              child: Container(
                color: Colors.grey.shade50,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // ✅ KRİTİK SATIR
                    children: [
                      RestaurantInfoSection(restaurant: restaurant),

                      // ✅ Artık görünür
                      RestaurantMapPreview(restaurant: restaurant),

                      RestaurantActions(restaurant: restaurant),
                      RestaurantMenuPlaceholder(restaurantId: restaurant.id),
                      RestaurantOsmFooter(restaurant: restaurant),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // ✅ Üstteki butonlar
        const RestaurantBackButton(),
        RestaurantFavoriteButton(restaurant: restaurant),

        // ✅ Stale indicator
        if (isStale) const RestaurantStaleDataIndicator(),
      ],
    );
  }
}
