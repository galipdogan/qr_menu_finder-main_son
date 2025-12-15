import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsLocalDataSource {
  Future<String> getLanguage();
  Future<void> setLanguage(String languageCode);

  Future<bool> areNotificationsEnabled();
  Future<void> setNotificationsEnabled(bool enabled);

  Future<String> getThemeMode();
  Future<void> setThemeMode(String themeMode);
}

const prefLanguageCode = 'PREF_LANGUAGE_CODE';
const prefNotificationsEnabled = 'PREF_NOTIFICATIONS_ENABLED';
const prefThemeMode = 'PREF_THEME_MODE';


class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;

  SettingsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<String> getLanguage() {
    final langCode = sharedPreferences.getString(prefLanguageCode);
    if (langCode != null) {
      return Future.value(langCode);
    } else {
      // Return default language, e.g., 'en'
      return Future.value('en');
    }
  }

  @override
  Future<void> setLanguage(String languageCode) {
    return sharedPreferences.setString(prefLanguageCode, languageCode);
  }

  @override
  Future<bool> areNotificationsEnabled() {
    final enabled = sharedPreferences.getBool(prefNotificationsEnabled);
    return Future.value(enabled ?? true); // Default to true
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) {
    return sharedPreferences.setBool(prefNotificationsEnabled, enabled);
  }
  
  @override
  Future<String> getThemeMode() {
    final themeMode = sharedPreferences.getString(prefThemeMode);
    return Future.value(themeMode ?? 'system'); // Default to system theme
  }

  @override
  Future<void> setThemeMode(String themeMode) {
    return sharedPreferences.setString(prefThemeMode, themeMode);
  }
}
