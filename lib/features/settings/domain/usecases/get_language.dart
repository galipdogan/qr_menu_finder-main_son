import 'package:dartz/dartz.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/settings/domain/repositories/settings_repository.dart';

class GetLanguage implements UseCase<String, NoParams> {
  final SettingsRepository repository;

  GetLanguage(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.getLanguage();
  }
}
