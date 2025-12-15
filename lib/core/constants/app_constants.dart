class AppConstants {
  // App Info
  static const String appName = 'QR Menu Finder';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String restaurantsCollection = 'restaurants';
  static const String menusCollection = 'menus';
  static const String itemsCollection = 'items';
  static const String itemsStagingCollection = 'items_staging';
  static const String reviewsCollection = 'reviews';

  // Storage Paths
  static const String menusStoragePath = 'menus';
  static const String profilesStoragePath = 'profiles';

  // Algolia
  static const String algoliaIndexName = 'items_idx';

  // Search & Pagination
  static const int defaultPageSize = 20;
  static const int maxPriceHistoryItems = 50;

  // Geolocation
  static const int defaultSearchRadiusMeters = 5000; // 5km
  static const int defaultGeohashPrecision = 7; // ~152m

  // OCR Confidence Thresholds
  static const double ocrAutoRejectThreshold = 0.50;
  static const double ocrManualReviewThreshold = 0.80;

  // Rate Limiting
  static const int maxReviewsPerDay = 5;
  static const int maxMenuUploadsPerDay = 10;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration searchDebounce = Duration(milliseconds: 300);

  // UI
  static const double defaultBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double defaultSpacing = 8.0;
  static const double buttonHeight = 44.0;

  // Image Settings
  static const int maxImageSizeMB = 10;
  static const int imageQuality = 85;

  // Currency
  static const String defaultCurrency = 'TRY';
  static const List<String> supportedCurrencies = ['TRY', 'USD', 'EUR'];

  // Units
  static const String defaultUnit = 'portion';
  static const List<String> supportedUnits = [
    'portion',
    'g',
    'kg',
    'ml',
    'l',
    'piece',
  ];

  // Rating
  static const double minRating = 1.0;
  static const double maxRating = 5.0;

  // Menu Types (Turkish)
  static const List<String> menuTypes = [
    'Kahvaltı',
    'Öğle Yemeği',
    'Akşam Yemeği',
    'İçecekler',
    'Tatlılar',
    'Aperatifler',
    'Ana Yemekler',
    'Başlangıçlar',
  ];

  // Categories
  static const List<String> foodCategories = [
    'Kebap',
    'Pizza',
    'Burger',
    'Döner',
    'Pide',
    'Lahmacun',
    'Balık',
    'Et Yemekleri',
    'Tavuk',
    'Salata',
    'Çorba',
    'Makarna',
    'Tatlı',
    'İçecek',
    'Kahvaltı',
  ];
}