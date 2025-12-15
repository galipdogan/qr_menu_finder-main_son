// Uygulama genelinde kullanılacak exception sınıfları

abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  const AppException(this.message, {this.code, this.originalError});
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Network ile ilgili hatalar
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.originalError});
}

/// Authentication ile ilgili hatalar
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.originalError});
}

/// Firestore ile ilgili hatalar
class FirestoreException extends AppException {
  const FirestoreException(super.message, {super.code, super.originalError});
}

/// Validation ile ilgili hatalar
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.originalError});
}

/// Permission ile ilgili hatalar
class PermissionException extends AppException {
  const PermissionException(super.message, {super.code, super.originalError});
}

/// Cache ile ilgili hatalar
class CacheException extends AppException {
  const CacheException(super.message, {super.code, super.originalError});
}

/// Server ile ilgili hatalar
class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.originalError});
}

/// Genel uygulama hataları
class GeneralException extends AppException {
  const GeneralException(super.message, {super.code, super.originalError});
}

/// Exception'ları user-friendly mesajlara çeviren utility
class ExceptionHandler {
  static String getDisplayMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    
    // Firebase Auth hataları
    if (error.toString().contains('user-not-found')) {
      return 'Kullanıcı bulunamadı';
    }
    if (error.toString().contains('wrong-password')) {
      return 'Hatalı şifre';
    }
    if (error.toString().contains('email-already-in-use')) {
      return 'Bu e-posta adresi zaten kullanımda';
    }
    if (error.toString().contains('weak-password')) {
      return 'Şifre çok zayıf';
    }
    if (error.toString().contains('invalid-email')) {
      return 'Geçersiz e-posta adresi';
    }
    
    // Network hataları
    if (error.toString().contains('network')) {
      return 'İnternet bağlantısını kontrol edin';
    }
    
    // Genel hata
    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }
}