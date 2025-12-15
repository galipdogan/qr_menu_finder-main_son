part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final String languageCode;
  final bool notificationsEnabled;
  final String themeMode;

  const SettingsLoaded({
    required this.languageCode,
    required this.notificationsEnabled,
    required this.themeMode,
  });

  @override
  List<Object> get props => [languageCode, notificationsEnabled, themeMode];
}

class SettingsFailure extends SettingsState {
  final String message;

  const SettingsFailure(this.message);

  @override
  List<Object> get props => [message];
}
