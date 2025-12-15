/// Kullanıcı dostu hata mesajları
class ErrorMessages {
  // Network errors
  static const String noInternet =
      'İnternet bağlantınızı kontrol edin ve tekrar deneyin.';
  static const String serverError =
      'Sunucuya bağlanırken bir sorun oluştu. Lütfen daha sonra tekrar deneyin.';
  static const String timeout =
      'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.';

  // Restaurant errors
  static const String restaurantNotFound =
      'Restoran bulunamadı. Restoran kaldırılmış olabilir.';
  static const String noRestaurantsNearby =
      'Yakınınızda restoran bulunamadı. Farklı bir konum deneyin.';
  static const String noRestaurantsFoundForSearch =
      'Aradığınız kritere uygun restoran bulunamadı.';
  static const String restaurantLoadFailed =
      'Restoranlar yüklenirken bir hata oluştu. Lütfen tekrar deneyin.';

  // Location errors
  static const String locationPermissionDenied =
      'Konum izni gerekli. Ayarlardan konum iznini açabilirsiniz.';
  static const String locationServiceDisabled =
      'Konum servisi kapalı. Lütfen konum servisini açın.';
  static const String locationFetchFailed =
      'Konumunuz alınamadı. Lütfen tekrar deneyin.';

  // Auth errors
  static const String notAuthenticated =
      'Bu işlem için giriş yapmalısınız.';
  static const String invalidCredentials =
      'E-posta veya şifre hatalı. Lütfen kontrol edin.';
  static const String userNotFound =
      'Kullanıcı bulunamadı. Kayıt olmayı deneyin.';
  static const String emailAlreadyInUse =
      'Bu e-posta adresi zaten kullanılıyor.';
  static const String weakPassword =
      'Şifre çok zayıf. En az 6 karakter kullanın.';
  static const String invalidEmail =
      'Geçersiz e-posta adresi. Lütfen kontrol edin.';

  // Menu errors
  static const String menuNotFound =
      'Menü bulunamadı. Restoran henüz menü eklememiş olabilir.';
  static const String menuLoadFailed =
      'Menü yüklenirken bir hata oluştu. Lütfen tekrar deneyin.';

  // Favorites errors
  static const String favoriteAddFailed =
      'Favorilere eklenirken bir hata oluştu. Lütfen tekrar deneyin.';
  static const String favoriteRemoveFailed =
      'Favorilerden kaldırılırken bir hata oluştu. Lütfen tekrar deneyin.';

  // General errors
  static const String unknownError =
      'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
  static const String operationFailed =
      'İşlem başarısız oldu. Lütfen tekrar deneyin.';

  /// Firebase hata kodlarını kullanıcı dostu mesajlara çevirir
  static String getFirebaseAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return userNotFound;
      case 'wrong-password':
      case 'invalid-credential': // Yeni Firebase hatası (yanlış şifre veya email)
        return invalidCredentials;
      case 'email-already-in-use':
        return emailAlreadyInUse;
      case 'weak-password':
        return weakPassword;
      case 'invalid-email':
        return invalidEmail;
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış. Destek ile iletişime geçin.';
      case 'too-many-requests':
        return 'Çok fazla deneme yaptınız. Lütfen daha sonra tekrar deneyin.';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda kullanılamıyor.';
      case 'network-request-failed':
        return noInternet;
      default:
        return unknownError;
    }
  }

  /// Genel hataları kullanıcı dostu mesajlara çevirir
  static String getErrorMessage(dynamic error) {
    if (error == null) return unknownError;

    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return noInternet;
    }

    // Timeout errors
    if (errorString.contains('timeout') ||
        errorString.contains('time out')) {
      return timeout;
    }

    // Not found errors
    if (errorString.contains('not found') ||
        errorString.contains('404')) {
      return 'İstediğiniz kaynak bulunamadı.';
    }

    // Server errors
    if (errorString.contains('500') ||
        errorString.contains('server') ||
        errorString.contains('internal')) {
      return serverError;
    }

    // Permission errors
    if (errorString.contains('permission')) {
      return 'İşlem için gerekli izin yok.';
    }

    return unknownError;
  }

  /// Hata mesajına göre ikon döndürür
  static String getErrorIcon(String errorMessage) {
    if (errorMessage.contains('İnternet') || errorMessage.contains('bağlantı')) {
      return '📶';
    }
    if (errorMessage.contains('Konum')) {
      return '📍';
    }
    if (errorMessage.contains('Giriş') || errorMessage.contains('Kullanıcı')) {
      return '🔐';
    }
    if (errorMessage.contains('Restoran')) {
      return '🍽️';
    }
    if (errorMessage.contains('Menü')) {
      return '📋';
    }
    return '⚠️';
  }
}
