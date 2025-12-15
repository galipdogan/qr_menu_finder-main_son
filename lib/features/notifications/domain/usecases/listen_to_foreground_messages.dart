import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/notifications/domain/repositories/notification_repository.dart';

class ListenToForegroundMessages implements StreamUseCase<RemoteMessage, NoParams> {
  final NotificationRepository repository;

  ListenToForegroundMessages(this.repository);

  @override
  Stream<Either<Failure, RemoteMessage>> call(NoParams params) {
    return repository.onMessage().map((message) => Right(message));
  }
}
