import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/update_profile.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  final String uid;

  const ProfileLoadRequested({required this.uid});

  @override
  List<Object> get props => [uid];
}

class ProfileUpdateRequested extends ProfileEvent {
  final User profile;

  const ProfileUpdateRequested({required this.profile});

  @override
  List<Object> get props => [profile];
}

class ProfileRefreshRequested extends ProfileEvent {
  final String uid;

  const ProfileRefreshRequested({required this.uid});

  @override
  List<Object> get props => [uid];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object> get props => [profile];
}

class ProfileUpdating extends ProfileState {
  final User currentProfile;

  const ProfileUpdating({required this.currentProfile});

  @override
  List<Object> get props => [currentProfile];
}

class ProfileUpdated extends ProfileState {
  final User profile;

  const ProfileUpdated({required this.profile});

  @override
  List<Object> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfile getUserProfile;
  final UpdateProfile updateProfile;

  ProfileBloc({
    required this.getUserProfile,
    required this.updateProfile,
  }) : super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfileRefreshRequested>(_onProfileRefreshRequested);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await getUserProfile(
      GetUserProfileParams(uid: event.uid),
    );

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;

    if (currentState is ProfileLoaded) {
      emit(ProfileUpdating(currentProfile: currentState.profile));
    }

    final result = await updateProfile(
      UpdateProfileParams(profile: event.profile),
    );

    result.fold(
      (failure) {
        emit(ProfileError(message: failure.message));
        // Return to previous state after showing error
        if (currentState is ProfileLoaded) {
          emit(currentState);
        }
      },
      (_) {
        emit(ProfileUpdated(profile: event.profile));
        // Reload profile after update
        add(ProfileLoadRequested(uid: event.profile.id));
      },
    );
  }

  Future<void> _onProfileRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // Don't show loading indicator on refresh
    final result = await getUserProfile(
      GetUserProfileParams(uid: event.uid),
    );

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }
}
