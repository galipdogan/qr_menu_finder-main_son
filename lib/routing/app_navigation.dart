import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'route_names.dart';
import '../features/restaurant/domain/entities/restaurant.dart';

/// Type-safe navigation helper sınıfı
class AppNavigation {
  // Ana navigasyon metodları
  static void goHome(BuildContext context) {
    context.go(RouteNames.home);
  }

  static void goLogin(BuildContext context) {
    context.go(RouteNames.login);
  }

  static void goSignup(BuildContext context) {
    context.go(RouteNames.signup);
  }

  // Restoran navigasyonu
  static void goRestaurantDetail(
    BuildContext context,
    String restaurantId, {
    Restaurant? initialRestaurant,
  }) {
    context.go(
      RouteNames.restaurantDetailPath(restaurantId),
      extra: initialRestaurant,
    );
  }

  static void pushRestaurantDetail(
    BuildContext context,
    String restaurantId, {
    Restaurant? initialRestaurant,
  }) {
    context.push(
      RouteNames.restaurantDetailPath(restaurantId),
      extra: initialRestaurant,
    );
  }

  static void goRestaurantSearch(BuildContext context) {
    context.go(RouteNames.restaurantSearch);
  }

  static Future<dynamic> pushRestaurantSearch(BuildContext context) {
    return context.push(RouteNames.restaurantSearch);
  }

  static void goAddRestaurant(BuildContext context) {
    context.go(RouteNames.addRestaurant);
  }

  static void pushRestaurantMap(
    BuildContext context, {
    List<Restaurant>? restaurants,
    double? latitude,
    double? longitude,
  }) {
    context.push(
      RouteNames.restaurantMap,
      extra: {
        'restaurants': restaurants,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  // Menü navigasyonu

  static Future<void> openDirections({
    required double lat,
    required double lon,
    required String name,
  }) async {
    // ✅ 1) Google Maps (Android + iOS)
    final googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lon",
    );

    // ✅ 2) Apple Maps (iOS)
    final appleMapsUrl = Uri.parse("https://maps.apple.com/?q=$lat,$lon");

    // ✅ 3) Yandex Maps (Android + iOS)
    final yandexUrl = Uri.parse("https://yandex.com/maps/?ll=$lon,$lat&z=16");

    // ✅ 4) OSM fallback
    final osmUrl = Uri.parse(
      "https://www.openstreetmap.org/?mlat=$lat&mlon=$lon&zoom=16",
    );

    // ✅ Google Maps (her zaman çalışır)
    if (await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
      return;
    }

    // ✅ Apple Maps
    if (await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication)) {
      return;
    }

    // ✅ Yandex Maps
    if (await launchUrl(yandexUrl, mode: LaunchMode.externalApplication)) {
      return;
    }

    // ✅ OSM fallback
    await launchUrl(osmUrl, mode: LaunchMode.externalApplication);
  }

  static void goAddMenu(
    BuildContext context,
    String restaurantId, {
    bool fromUrl = false,
  }) {
    final uri = Uri.parse(RouteNames.addMenuPath(restaurantId));
    final queryParams = fromUrl ? {'fromUrl': 'true'} : <String, String>{};
    final path = uri.replace(queryParameters: queryParams).toString();
    context.go(path);
  }

  static void pushAddMenu(
    BuildContext context,
    String restaurantId, {
    bool fromUrl = false,
  }) {
    final uri = Uri.parse(RouteNames.addMenuPath(restaurantId));
    final queryParams = fromUrl ? {'fromUrl': 'true'} : <String, String>{};
    final path = uri.replace(queryParameters: queryParams).toString();
    context.push(path);
  }

  static void goItemDetail(
    BuildContext context,
    String restaurantId,
    String itemId,
  ) {
    context.go(RouteNames.itemDetailPath(restaurantId, itemId));
  }

  static void pushItemDetail(
    BuildContext context,
    String restaurantId,
    String itemId,
  ) {
    context.push(RouteNames.itemDetailPath(restaurantId, itemId));
  }

  // OCR navigasyonu
  static void goOcrVerification(BuildContext context, String restaurantId) {
    context.go(RouteNames.ocrVerificationPath(restaurantId));
  }

  static void pushOcrVerification(BuildContext context, String restaurantId) {
    context.push(RouteNames.ocrVerificationPath(restaurantId));
  }

  // Diğer özellikler

  static Future<void> launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception("Could not launch $url");
    }
  }

  static void goQrScanner(BuildContext context) {
    context.go(RouteNames.qrScanner);
  }

  static void goDebugSearch(BuildContext context) {
    context.go(RouteNames.debugSearch);
  }

  static Future<dynamic> pushQrScanner(BuildContext context) {
    return context.push(RouteNames.qrScanner);
  }

  static void goSearch(BuildContext context) {
    context.go(RouteNames.search);
  }

  static void pushSearch(BuildContext context) {
    context.push(RouteNames.search);
  }

  // Profil navigasyonu
  static void goProfile(BuildContext context) {
    context.go(RouteNames.profile);
  }

  static void goEditProfile(BuildContext context) {
    context.go(RouteNames.editProfile);
  }

  static void goFavorites(BuildContext context) {
    context.go(RouteNames.favorites);
  }

  static void goHistory(BuildContext context) {
    context.go(RouteNames.history);
  }

  static void goSettings(BuildContext context) {
    context.go(RouteNames.settings);
  }

  // Owner panel
  static void goOwnerPanel(BuildContext context) {
    context.go(RouteNames.ownerPanel);
  }

  // Yorumlar
  static void goComments(BuildContext context, String restaurantId) {
    context.go(RouteNames.commentsPath(restaurantId));
  }

  static void pushComments(BuildContext context, String restaurantId) {
    context.push(RouteNames.commentsPath(restaurantId));
  }

  // Utility metodlar
  static void pop(BuildContext context) {
    context.pop();
  }

  static bool canPop(BuildContext context) {
    return context.canPop();
  }

  static void popUntil(BuildContext context, String routeName) {
    while (context.canPop()) {
      context.pop();
      if (GoRouterState.of(context).fullPath == routeName) {
        break;
      }
    }
  }
}
