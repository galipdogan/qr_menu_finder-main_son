import 'package:dartz/dartz.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/settings/domain/repositories/settings_repository.dart';

class GetNotificationsStatus implements UseCase<bool, NoParams> {
  final SettingsRepository repository;

  GetNotificationsStatus(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.areNotificationsEnabled();
  }
}
