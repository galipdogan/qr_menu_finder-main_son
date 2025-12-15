part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class InitializeNotifications extends NotificationEvent {
  const InitializeNotifications();
}

class RequestNotificationPermissionEvent extends NotificationEvent {
  const RequestNotificationPermissionEvent();
}

class FCMTokenReceived extends NotificationEvent {
  final String token;
  const FCMTokenReceived(this.token);

  @override
  List<Object> get props => [token];
}

class ForegroundMessageReceived extends NotificationEvent {
  final RemoteMessage message;
  const ForegroundMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class OpenedAppMessageReceived extends NotificationEvent {
  final RemoteMessage message;
  const OpenedAppMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class NotificationTokenRefreshed extends NotificationEvent {
  final String token;
  const NotificationTokenRefreshed(this.token);

  @override
  List<Object> get props => [token];
}

class SaveFCMTokenRequested extends NotificationEvent {
  final String userId;
  final String? token;
  const SaveFCMTokenRequested({required this.userId, this.token});

  @override
  List<Object> get props => [userId, token ?? ''];
}

class RemoveFCMTokenRequested extends NotificationEvent {
  final String userId;
  final String? token;
  const RemoveFCMTokenRequested({required this.userId, this.token});

  @override
  List<Object> get props => [userId, token ?? ''];
}
