/// Reusable form validators for authentication
/// 
/// Provides consistent validation logic across auth forms
class AuthValidators {
  AuthValidators._(); // Private constructor to prevent instantiation

  /// Email validator
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta gerekli';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  /// Password validator (minimum 6 characters)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    return null;
  }

  /// Confirm password validator
  static String? Function(String?) confirmPassword(String originalPassword) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Şifre tekrarı gerekli';
      }
      if (value != originalPassword) {
        return 'Şifreler eşleşmiyor';
      }
      return null;
    };
  }

  /// Display name validator
  static String? displayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ad Soyad gerekli';
    }
    if (value.length < 3) {
      return 'Ad Soyad en az 3 karakter olmalı';
    }
    return null;
  }

  /// Required field validator
  static String? required(String? value, {String fieldName = 'Bu alan'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName gerekli';
    }
    return null;
  }

  /// Minimum length validator
  static String? Function(String?) minLength(int length, {String? fieldName}) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return '${fieldName ?? "Bu alan"} gerekli';
      }
      if (value.length < length) {
        return '${fieldName ?? "Bu alan"} en az $length karakter olmalı';
      }
      return null;
    };
  }
}
