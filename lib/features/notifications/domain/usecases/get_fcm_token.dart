import 'package:dartz/dartz.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/notifications/domain/repositories/notification_repository.dart';

class GetFCMToken implements UseCase<String, NoParams> {
  final NotificationRepository repository;

  GetFCMToken(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.getFCMToken();
  }
}
