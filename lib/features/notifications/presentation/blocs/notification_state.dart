part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationReady extends NotificationState {
  final AuthorizationStatus authorizationStatus;
  final String? fcmToken;
  final RemoteMessage? lastForegroundMessage;
  final RemoteMessage? lastOpenedAppMessage;

  const NotificationReady({
    required this.authorizationStatus,
    this.fcmToken,
    this.lastForegroundMessage,
    this.lastOpenedAppMessage,
  });

  NotificationReady copyWith({
    AuthorizationStatus? authorizationStatus,
    String? fcmToken,
    RemoteMessage? lastForegroundMessage,
    RemoteMessage? lastOpenedAppMessage,
  }) {
    return NotificationReady(
      authorizationStatus: authorizationStatus ?? this.authorizationStatus,
      fcmToken: fcmToken ?? this.fcmToken,
      lastForegroundMessage: lastForegroundMessage ?? this.lastForegroundMessage,
      lastOpenedAppMessage: lastOpenedAppMessage ?? this.lastOpenedAppMessage,
    );
  }

  @override
  List<Object> get props => [authorizationStatus, fcmToken ?? '', lastForegroundMessage ?? '', lastOpenedAppMessage ?? ''];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);

  @override
  List<Object> get props => [message];
}
