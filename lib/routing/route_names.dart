class RouteNames {
  // Ana sayfa
  static const String home = '/';

  // Auth
  static const String login = '/login';
  static const String signup = '/signup';

  // Restoran
  static const String restaurantDetail = '/restaurant/:id';
  static const String restaurantSearch = '/restaurant/search';
  static const String restaurantMap = '/restaurant/map';
  static const String addRestaurant = '/restaurant/add';

  // Menü
  static const String addMenu = '/restaurant/:restaurantId/add-menu';
  static const String menuItem = '/restaurant/:restaurantId/item/:id';

  // OCR
  static const String ocrVerification = '/restaurant/:restaurantId/ocr';

  // QR
  static const String qrScanner = '/qr-scanner';

  // Arama
  static const String search = '/search';

  // Profil
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String favorites = '/profile/favorites';
  static const String history = '/profile/history';
  static const String settings = '/profile/settings';

  // Owner
  static const String ownerPanel = '/owner/panel';

  // Yorumlar
  static const String comments = '/restaurant/:restaurantId/comments';

  // ---------------------------
  // ✅ Helper Methods
  // ---------------------------

  // Restoran detay path
  static String restaurantDetailPath(String id) => '/restaurant/$id';

  // Menü ekleme path
  static String addMenuPath(String restaurantId) =>
      '/restaurant/$restaurantId/add-menu';

  // Menü item detay path
  static String menuItemPath(String restaurantId, String itemId) =>
      '/restaurant/$restaurantId/item/$itemId';

  static const String menu = '/restaurant/:restaurantId/menu';

  static String menuPath(String restaurantId) =>
      '/restaurant/$restaurantId/menu';

  // OCR path
  static String ocrVerificationPath(String restaurantId) =>
      '/restaurant/$restaurantId/ocr';

  // Yorumlar path
  static String commentsPath(String restaurantId) =>
      '/restaurant/$restaurantId/comments';

  static String itemDetailPath(String restaurantId, String itemId) =>
      '/restaurant/$restaurantId/item/$itemId';

  static const String debugSearch = '/debug-search';
}
