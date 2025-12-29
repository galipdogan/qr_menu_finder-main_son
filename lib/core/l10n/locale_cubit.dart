import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locale Cubit - Dil yönetimi için
class LocaleCubit extends Cubit<Locale> {
  static const String _localeKey = 'app_locale';
  final SharedPreferences _prefs;

  LocaleCubit(this._prefs) : super(const Locale('tr')) {
    _loadSavedLocale();
  }

  /// Kaydedilmiş dili yükle
  void _loadSavedLocale() {
    final savedLocale = _prefs.getString(_localeKey);
    if (savedLocale != null) {
      emit(Locale(savedLocale));
    }
  }

  /// Dili değiştir
  Future<void> changeLocale(String languageCode) async {
    await _prefs.setString(_localeKey, languageCode);
    emit(Locale(languageCode));
  }

  /// Türkçe'ye geç
  Future<void> setTurkish() => changeLocale('tr');

  /// İngilizce'ye geç
  Future<void> setEnglish() => changeLocale('en');
}
