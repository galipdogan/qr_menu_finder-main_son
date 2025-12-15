import 'package:dartz/dartz.dart';
import 'package:qr_menu_finder/core/error/failures.dart';

abstract class SettingsRepository {
  Future<Either<Failure, String>> getLanguage();
  Future<Either<Failure, void>> setLanguage(String languageCode);

  Future<Either<Failure, bool>> areNotificationsEnabled();
  Future<Either<Failure, void>> setNotificationsEnabled(bool enabled);
  
  Future<Either<Failure, String>> getThemeMode();
  Future<Either<Failure, void>> setThemeMode(String themeMode);
}
