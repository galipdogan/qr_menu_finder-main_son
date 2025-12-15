import 'package:dartz/dartz.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/utils/repository_helper.dart';
import 'package:qr_menu_finder/features/settings/domain/repositories/settings_repository.dart';
import 'package:qr_menu_finder/features/settings/data/datasources/settings_local_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, String>> getLanguage() async {
    return RepositoryHelper.execute(
      () => localDataSource.getLanguage(),
      (langCode) => langCode as String,
    );
  }

  @override
  Future<Either<Failure, void>> setLanguage(String languageCode) async {
    return RepositoryHelper.executeVoid(
      () => localDataSource.setLanguage(languageCode),
    );
  }

  @override
  Future<Either<Failure, bool>> areNotificationsEnabled() async {
    return RepositoryHelper.execute(
      () => localDataSource.areNotificationsEnabled(),
      (enabled) => enabled as bool,
    );
  }

  @override
  Future<Either<Failure, void>> setNotificationsEnabled(bool enabled) async {
    return RepositoryHelper.executeVoid(
      () => localDataSource.setNotificationsEnabled(enabled),
    );
  }

  @override
  Future<Either<Failure, String>> getThemeMode() async {
    return RepositoryHelper.execute(
      () => localDataSource.getThemeMode(),
      (themeMode) => themeMode as String,
    );
  }

  @override
  Future<Either<Failure, void>> setThemeMode(String themeMode) async {
    return RepositoryHelper.executeVoid(
      () => localDataSource.setThemeMode(themeMode),
    );
  }
}
