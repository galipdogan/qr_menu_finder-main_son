import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:qr_menu_finder/core/error/failures.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/notifications/domain/usecases/get_fcm_token.dart';
import 'package:qr_menu_finder/features/notifications/domain/usecases/get_notification_settings.dart';
import 'package:qr_menu_finder/features/notifications/domain/usecases/listen_to_foreground_messages.dart';
import 'package:qr_menu_finder/features/notifications/domain/usecases/listen_to_opened_app_messages.dart';
import 'package:qr_menu_finder/features/notifications/domain/usecases/listen_to_token_refresh.dart';
import 'package:qr_menu_finder/features/notifications/domain/usecases/request_notification_permission.dart';
import 'package:qr_menu_finder/features/notifications/domain/usecases/save_fcm_token_for_user.dart';
import 'package:qr_menu_finder/features/notifications/domain/usecases/remove_fcm_token_for_user.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final RequestNotificationPermission requestNotificationPermission;
  final GetFCMToken getFCMToken;
  final GetNotificationSettings getNotificationSettings;
  final ListenToForegroundMessages listenToForegroundMessages;
  final ListenToOpenedAppMessages listenToOpenedAppMessages;
  final ListenToTokenRefresh listenToTokenRefresh;
  final SaveFCMTokenForUser saveFCMTokenForUser;
  final RemoveFCMTokenForUser removeFCMTokenForUser;

  StreamSubscription<Either<Failure, RemoteMessage>>?
  _foregroundMessageSubscription;
  StreamSubscription<Either<Failure, RemoteMessage>>?
  _openedAppMessageSubscription;
  StreamSubscription<Either<Failure, String>>? _tokenRefreshSubscription;

  NotificationBloc({
    required this.requestNotificationPermission,
    required this.getFCMToken,
    required this.getNotificationSettings,
    required this.listenToForegroundMessages,
    required this.listenToOpenedAppMessages,
    required this.listenToTokenRefresh,
    required this.saveFCMTokenForUser,
    required this.removeFCMTokenForUser,
  }) : super(NotificationInitial()) {
    on<InitializeNotifications>(_onInitializeNotifications);
    on<RequestNotificationPermissionEvent>(
      _onRequestNotificationPermissionEvent,
    );
    on<FCMTokenReceived>(_onFCMTokenReceived);
    on<ForegroundMessageReceived>(_onForegroundMessageReceived);
    on<OpenedAppMessageReceived>(_onOpenedAppMessageReceived);
    on<NotificationTokenRefreshed>(_onNotificationTokenRefreshed);
    on<SaveFCMTokenRequested>(_onSaveFCMTokenRequested);
    on<RemoveFCMTokenRequested>(_onRemoveFCMTokenRequested);
  }

  Future<void> _onInitializeNotifications(
    InitializeNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final permissionResult = await requestNotificationPermission(NoParams());

    permissionResult.fold(
      (failure) {
        emit(NotificationError(failure.message));
      },
      (status) async {
        final tokenResult = await getFCMToken(NoParams());
        tokenResult.fold(
          (failure) {
            emit(NotificationError(failure.message));
          },
          (fcmToken) {
            _subscribeToMessageStreams(emit);
            _subscribeToTokenRefreshStream(emit);
            emit(
              NotificationReady(
                authorizationStatus: status,
                fcmToken: fcmToken,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onRequestNotificationPermissionEvent(
    RequestNotificationPermissionEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await requestNotificationPermission(NoParams());
    result.fold((failure) => emit(NotificationError(failure.message)), (
      status,
    ) {
      if (state is NotificationReady) {
        emit(
          (state as NotificationReady).copyWith(authorizationStatus: status),
        );
      } else {
        // If not ready, transition to ready with new status
        emit(NotificationReady(authorizationStatus: status));
      }
    });
  }

  void _onFCMTokenReceived(
    FCMTokenReceived event,
    Emitter<NotificationState> emit,
  ) {
    if (state is NotificationReady) {
      emit((state as NotificationReady).copyWith(fcmToken: event.token));
    }
  }

  void _onForegroundMessageReceived(
    ForegroundMessageReceived event,
    Emitter<NotificationState> emit,
  ) {
    if (state is NotificationReady) {
      emit(
        (state as NotificationReady).copyWith(
          lastForegroundMessage: event.message,
        ),
      );
    }
  }

  void _onOpenedAppMessageReceived(
    OpenedAppMessageReceived event,
    Emitter<NotificationState> emit,
  ) {
    if (state is NotificationReady) {
      emit(
        (state as NotificationReady).copyWith(
          lastOpenedAppMessage: event.message,
        ),
      );
    }
  }

  void _onNotificationTokenRefreshed(
    NotificationTokenRefreshed event,
    Emitter<NotificationState> emit,
  ) {
    if (state is NotificationReady) {
      emit((state as NotificationReady).copyWith(fcmToken: event.token));
    }
  }

  Future<void> _onSaveFCMTokenRequested(
    SaveFCMTokenRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await saveFCMTokenForUser(
      SaveFCMTokenParams(
        userId: event.userId,
        token:
            event.token ??
            (state is NotificationReady
                ? (state as NotificationReady).fcmToken
                : null),
      ),
    );
    result.fold((failure) => emit(NotificationError(failure.message)), (_) {
      // Optionally emit a success state or log
    });
  }

  Future<void> _onRemoveFCMTokenRequested(
    RemoveFCMTokenRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await removeFCMTokenForUser(
      RemoveFCMTokenParams(
        userId: event.userId,
        token:
            event.token ??
            (state is NotificationReady
                ? (state as NotificationReady).fcmToken
                : null),
      ),
    );
    result.fold((failure) => emit(NotificationError(failure.message)), (_) {
      // Optionally emit a success state or log
    });
  }

  void _subscribeToMessageStreams(Emitter<NotificationState> emit) {
    _foregroundMessageSubscription = listenToForegroundMessages(NoParams())
        .listen(
          (either) => either.fold((failure) {
            // Emit error state instead of adding error event
            emit(NotificationError(failure.message));
          }, (message) => add(ForegroundMessageReceived(message))),
        );

    _openedAppMessageSubscription = listenToOpenedAppMessages(NoParams())
        .listen(
          (either) => either.fold((failure) {
            emit(NotificationError(failure.message));
          }, (message) => add(OpenedAppMessageReceived(message))),
        );
  }

  void _subscribeToTokenRefreshStream(Emitter<NotificationState> emit) {
    _tokenRefreshSubscription = listenToTokenRefresh(NoParams()).listen(
      (either) => either.fold((failure) {
        emit(NotificationError(failure.message));
      }, (token) => add(NotificationTokenRefreshed(token))),
    );
  }

  @override
  Future<void> close() {
    _foregroundMessageSubscription?.cancel();
    _openedAppMessageSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
    return super.close();
  }
}
