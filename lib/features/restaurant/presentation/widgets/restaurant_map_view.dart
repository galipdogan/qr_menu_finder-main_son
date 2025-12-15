import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/restaurant.dart';
import '../../../../core/theme/app_colors.dart';

/// Restaurant map view widget with OpenStreetMap
class RestaurantMapView extends StatefulWidget {
  final List<Restaurant> restaurants;
  final double userLatitude;
  final double userLongitude;
  final Function(Restaurant) onRestaurantTap;

  const RestaurantMapView({
    super.key,
    required this.restaurants,
    required this.userLatitude,
    required this.userLongitude,
    required this.onRestaurantTap,
  });

  @override
  State<RestaurantMapView> createState() => _RestaurantMapViewState();
}

class _RestaurantMapViewState extends State<RestaurantMapView> {
  final MapController _mapController = MapController();
  Restaurant? _selectedRestaurant;

  @override
  void initState() {
    super.initState();
  }

  List<Marker> _createMarkers() {
    final markers = <Marker>[];

    // User location marker
    markers.add(
      Marker(
        point: LatLng(widget.userLatitude, widget.userLongitude),
        width: 40,
        height: 40,
        child: const Icon(
          Icons.my_location,
          color: Colors.blue,
          size: 30,
        ),
      ),
    );

    // Restaurant markers
    for (final restaurant in widget.restaurants) {
      if (restaurant.latitude != null && restaurant.longitude != null) {
        markers.add(
          Marker(
            point: LatLng(restaurant.latitude!, restaurant.longitude!),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedRestaurant = restaurant);
              },
              child: const Icon(
                Icons.restaurant,
                color: Colors.red,
                size: 30,
              ),
            ),
          ),
        );
      }
    }

    return markers;
  }

  void _fitMapToMarkers() {
    if (widget.restaurants.isEmpty) return;

    final points = <LatLng>[
      LatLng(widget.userLatitude, widget.userLongitude),
    ];

    for (final restaurant in widget.restaurants) {
      if (restaurant.latitude != null && restaurant.longitude != null) {
        points.add(LatLng(restaurant.latitude!, restaurant.longitude!));
      }
    }

    if (points.length > 1) {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(widget.userLatitude, widget.userLongitude),
            initialZoom: 14,
            onMapReady: _fitMapToMarkers,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.qr_menu_finder',
            ),
            MarkerLayer(
              markers: _createMarkers(),
            ),
          ],
        ),

        // Map controls
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: 'zoom_in',
                onPressed: () {
                  final zoom = _mapController.camera.zoom + 1;
                  _mapController.move(_mapController.camera.center, zoom);
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.add, color: Colors.black),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'zoom_out',
                onPressed: () {
                  final zoom = _mapController.camera.zoom - 1;
                  _mapController.move(_mapController.camera.center, zoom);
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.remove, color: Colors.black),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'my_location',
                onPressed: () {
                  _mapController.move(
                    LatLng(widget.userLatitude, widget.userLongitude),
                    14,
                  );
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.my_location, color: Colors.black),
              ),
            ],
          ),
        ),

        // Selected restaurant info card
        if (_selectedRestaurant != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => widget.onRestaurantTap(_selectedRestaurant!),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedRestaurant!.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_selectedRestaurant!.address != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _selectedRestaurant!.address!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (_selectedRestaurant!.rating != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    _selectedRestaurant!.rating!.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Close button for selected restaurant
        if (_selectedRestaurant != null)
          Positioned(
            bottom: 200,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'close_selection',
              onPressed: () => setState(() => _selectedRestaurant = null),
              backgroundColor: Colors.white,
              child: const Icon(Icons.close, color: Colors.black),
            ),
          ),
      ],
    );
  }
}