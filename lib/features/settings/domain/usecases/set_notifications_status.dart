import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/settings/domain/repositories/settings_repository.dart';

class SetNotificationsStatus implements UseCase<void, SetNotificationsStatusParams> {
  final SettingsRepository repository;

  SetNotificationsStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(SetNotificationsStatusParams params) async {
    return await repository.setNotificationsEnabled(params.enabled);
  }
}

class SetNotificationsStatusParams extends Equatable {
  final bool enabled;

  const SetNotificationsStatusParams({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}
