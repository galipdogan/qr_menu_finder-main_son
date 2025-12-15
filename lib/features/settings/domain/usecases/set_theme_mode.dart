import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/settings/domain/repositories/settings_repository.dart';

class SetThemeMode implements UseCase<void, SetThemeModeParams> {
  final SettingsRepository repository;

  SetThemeMode(this.repository);

  @override
  Future<Either<Failure, void>> call(SetThemeModeParams params) async {
    return await repository.setThemeMode(params.themeMode);
  }
}

class SetThemeModeParams extends Equatable {
  final String themeMode;

  const SetThemeModeParams({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}
