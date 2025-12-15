import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/notifications/domain/repositories/notification_repository.dart';

class RequestNotificationPermission implements UseCase<AuthorizationStatus, NoParams> {
  final NotificationRepository repository;

  RequestNotificationPermission(this.repository);

  @override
  Future<Either<Failure, AuthorizationStatus>> call(NoParams params) async {
    return await repository.requestPermission();
  }
}
