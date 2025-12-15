import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration utility
/// Loads and provides access to environment variables from .env file
class EnvConfig {
  /// Initialize environment variables
  static Future<void> init() async {
    try {
      // Try to load from assets folder (required for Flutter Web)
      await dotenv.load(fileName: 'assets/.env');
      if (kDebugMode) {
        // ignore: avoid_print
        print('EnvConfig: Loaded assets/.env');
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('EnvConfig: assets/.env not found or failed to load: $e');
        print('EnvConfig: Attempting to load assets/.env.example as fallback');
      }

      try {
        await dotenv.load(fileName: 'assets/.env.example');
        if (kDebugMode) {
          // ignore: avoid_print
          print('EnvConfig: Loaded assets/.env.example as fallback');
        }
      } catch (e2) {
        if (kDebugMode) {
          // ignore: avoid_print
          print(
            'EnvConfig: assets/.env.example not found or failed to load: $e2',
          );
        }
      }
    }
  }

  // Algolia Configuration
  static String get algoliaAppId => dotenv.get('ALGOLIA_APP_ID', fallback: '');
  static String get algoliaApiKey =>
      dotenv.get('ALGOLIA_SEARCH_API_KEY', fallback: '');
  static String get algoliaSearchKey =>
      dotenv.get('ALGOLIA_SEARCH_API_KEY', fallback: '');
  static String get algoliaAdminKey =>
      dotenv.get('ALGOLIA_ADMIN_API_KEY', fallback: '');
  static String get algoliaIndexName =>
      dotenv.get('ALGOLIA_INDEX_NAME', fallback: 'restaurants');

  // OpenStreetMap - No API keys needed! 🎉
  // OpenStreetMap - API anahtarı gerekmiyor! 🎉
  //
  // We use Nominatim and Photon APIs which are completely free
  // Tamamen ücretsiz olan Nominatim ve Photon API'lerini kullanıyoruz

  // Firebase
  static String get firebaseApiKeyAndroid =>
      dotenv.get('FIREBASE_API_KEY_ANDROID', fallback: '');
  static String get firebaseApiKeyIOS =>
      dotenv.get('FIREBASE_API_KEY_IOS', fallback: '');
  static String get firebaseApiKeyWeb =>
      dotenv.get('FIREBASE_API_KEY_WEB', fallback: '');
  static String get firebaseProjectId =>
      dotenv.get('FIREBASE_PROJECT_ID', fallback: 'qrmenufinder');

  // App Check / ReCAPTCHA
  static String get recaptchaSiteKey =>
      dotenv.get('RECAPTCHA_SITE_KEY', fallback: '');

  /// Check if all required environment variables are set
  /// TR: Tüm gerekli ortam değişkenlerinin ayarlanıp ayarlanmadığını kontrol et
  static bool get isConfigured {
    return algoliaAppId.isNotEmpty && algoliaSearchKey.isNotEmpty;
    // Note: Google Places API key no longer required!
    // Not: Google Places API anahtarı artık gerekli değil!
  }

  /// Get configuration status message
  /// TR: Yapılandırma durum mesajını al
  static String getConfigStatus() {
    final missing = <String>[];

    if (algoliaAppId.isEmpty) missing.add('ALGOLIA_APP_ID');
    if (algoliaSearchKey.isEmpty) missing.add('ALGOLIA_SEARCH_API_KEY');
    // Google Places API key no longer checked
    // Google Places API anahtarı artık kontrol edilmiyor

    if (missing.isEmpty) {
      return 'All environment variables configured ✓\n'
          'Using Nominatim (FREE) for restaurant search! 🎉';
    } else {
      return 'Missing: ${missing.join(', ')}';
    }
  }
}
