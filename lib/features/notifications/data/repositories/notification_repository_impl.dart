import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/error/exceptions.dart';
import 'package:qr_menu_finder/core/utils/repository_helper.dart';
import 'package:qr_menu_finder/features/notifications/domain/repositories/notification_repository.dart';
import 'package:qr_menu_finder/features/notifications/data/datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AuthorizationStatus>> requestPermission() async {
    return RepositoryHelper.execute(
      () => remoteDataSource.requestPermission(),
      (status) => status as AuthorizationStatus,
    );
  }

  @override
  Future<Either<Failure, String>> getFCMToken() async {
    return RepositoryHelper.execute(() async {
      final token = await remoteDataSource.getFCMToken();
      if (token == null) {
        throw ServerException('FCM token is null');
      }
      return token;
    }, (token) => token as String);
  }

  @override
  Future<Either<Failure, AuthorizationStatus>> getNotificationSettings() async {
    return RepositoryHelper.execute(
      () => remoteDataSource.getNotificationSettings(),
      (status) => status as AuthorizationStatus,
    );
  }

  @override
  Stream<RemoteMessage> onMessage() {
    return remoteDataSource.onMessage();
  }

  @override
  Stream<RemoteMessage> onMessageOpenedApp() {
    return remoteDataSource.onMessageOpenedApp();
  }

  @override
  Stream<String> onTokenRefresh() {
    return remoteDataSource.onTokenRefresh();
  }

  @override
  Future<Either<Failure, void>> saveFCMTokenToFirestore(
    String userId,
    String? token,
  ) async {
    return RepositoryHelper.executeVoid(
      () => remoteDataSource.saveFCMTokenToFirestore(userId, token),
    );
  }

  @override
  Future<Either<Failure, void>> removeFCMTokenFromFirestore(
    String userId,
    String? token,
  ) async {
    return RepositoryHelper.executeVoid(
      () => remoteDataSource.removeFCMTokenFromFirestore(userId, token),
    );
  }
}
