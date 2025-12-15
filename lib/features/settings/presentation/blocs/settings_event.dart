part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSettings extends SettingsEvent {}

class LanguageChanged extends SettingsEvent {
  final String languageCode;

  const LanguageChanged(this.languageCode);

  @override
  List<Object> get props => [languageCode];
}

class NotificationsToggled extends SettingsEvent {
  final bool isEnabled;

  const NotificationsToggled(this.isEnabled);

  @override
  List<Object> get props => [isEnabled];
}

class ThemeChanged extends SettingsEvent {
  final String themeMode;

  const ThemeChanged(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}
