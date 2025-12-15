import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class NotificationRemoteDataSource {
  Future<AuthorizationStatus> requestPermission();
  Future<String?> getFCMToken();
  Future<AuthorizationStatus> getNotificationSettings();
  
  Stream<RemoteMessage> onMessage();
  Stream<RemoteMessage> onMessageOpenedApp();
  Stream<String> onTokenRefresh();

  Future<void> saveFCMTokenToFirestore(String userId, String? token);
  Future<void> removeFCMTokenFromFirestore(String userId, String? token);
}

class FirebaseNotificationDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseMessaging firebaseMessaging;
  final FirebaseFirestore firestore;

  FirebaseNotificationDataSourceImpl({
    required this.firebaseMessaging,
    required this.firestore,
  });

  @override
  Future<AuthorizationStatus> requestPermission() async {
    final settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    return settings.authorizationStatus;
  }

  @override
  Future<String?> getFCMToken() async {
    return await firebaseMessaging.getToken();
  }

  @override
  Future<AuthorizationStatus> getNotificationSettings() async {
    final settings = await firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  @override
  Stream<RemoteMessage> onMessage() {
    return FirebaseMessaging.onMessage;
  }

  @override
  Stream<RemoteMessage> onMessageOpenedApp() {
    return FirebaseMessaging.onMessageOpenedApp;
  }

  @override
  Stream<String> onTokenRefresh() {
    return firebaseMessaging.onTokenRefresh;
  }

  @override
  Future<void> saveFCMTokenToFirestore(String userId, String? token) async {
    if (token != null) {
      await firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> removeFCMTokenFromFirestore(String userId, String? token) async {
    if (token != null) {
      await firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    }
  }
}
