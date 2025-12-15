import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/restaurant.dart';

class RestaurantMapPreview extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantMapPreview({super.key, required this.restaurant});

  // ✅ Lat/Lon → Tile X/Y dönüşümü
  int _lon2tile(double lon, int zoom) =>
      ((lon + 180.0) / 360.0 * pow(2.0, zoom)).floor();

  int _lat2tile(double lat, int zoom) =>
      ((1.0 - log(tan(lat * pi / 180.0) + 1 / cos(lat * pi / 180.0)) / pi) /
              2.0 *
              pow(2.0, zoom))
          .floor();

  @override
  Widget build(BuildContext context) {
    final lat = restaurant.latitude;
    final lon = restaurant.longitude;

    if (lat == null || lon == null) {
      return const SizedBox.shrink();
    }

    const zoom = 16;

    final x = _lon2tile(lon, zoom);
    final y = _lat2tile(lat, zoom);

    final tileUrl = "https://tile.openstreetmap.org/$zoom/$x/$y.png";

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          // ✅ Gerçek OSM tile
          Image.network(
            tileUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: const Text("Harita yüklenemedi"),
            ),
          ),

          // ✅ Kırmızı pin overlay
          const Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        ],
      ),
    );
  }
}
