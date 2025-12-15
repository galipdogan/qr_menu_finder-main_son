import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:qr_menu_finder/core/error/failures.dart';

abstract class NotificationRepository {
  Future<Either<Failure, AuthorizationStatus>> requestPermission();
  Future<Either<Failure, String>> getFCMToken();
  Future<Either<Failure, AuthorizationStatus>> getNotificationSettings();
  
  Stream<RemoteMessage> onMessage();
  Stream<RemoteMessage> onMessageOpenedApp();
  Stream<String> onTokenRefresh();

  Future<Either<Failure, void>> saveFCMTokenToFirestore(String userId, String? token);
  Future<Either<Failure, void>> removeFCMTokenFromFirestore(String userId, String? token);
}
