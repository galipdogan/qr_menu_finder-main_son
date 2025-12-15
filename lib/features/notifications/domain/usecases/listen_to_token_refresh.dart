import 'package:dartz/dartz.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/notifications/domain/repositories/notification_repository.dart';

class ListenToTokenRefresh implements StreamUseCase<String, NoParams> {
  final NotificationRepository repository;

  ListenToTokenRefresh(this.repository);

  @override
  Stream<Either<Failure, String>> call(NoParams params) {
    return repository.onTokenRefresh().map((token) => Right(token));
  }
}
