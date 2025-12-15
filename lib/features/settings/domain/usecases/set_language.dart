import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/settings/domain/repositories/settings_repository.dart';

class SetLanguage implements UseCase<void, SetLanguageParams> {
  final SettingsRepository repository;

  SetLanguage(this.repository);

  @override
  Future<Either<Failure, void>> call(SetLanguageParams params) async {
    return await repository.setLanguage(params.languageCode);
  }
}

class SetLanguageParams extends Equatable {
  final String languageCode;

  const SetLanguageParams({required this.languageCode});

  @override
  List<Object?> get props => [languageCode];
}
