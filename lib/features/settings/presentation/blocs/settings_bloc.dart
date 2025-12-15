import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/settings/domain/usecases/get_language.dart';
import 'package:qr_menu_finder/features/settings/domain/usecases/set_language.dart';
import 'package:qr_menu_finder/features/settings/domain/usecases/get_notifications_status.dart';
import 'package:qr_menu_finder/features/settings/domain/usecases/set_notifications_status.dart';
import 'package:qr_menu_finder/features/settings/domain/usecases/get_theme_mode.dart';
import 'package:qr_menu_finder/features/settings/domain/usecases/set_theme_mode.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetLanguage getLanguage;
  final SetLanguage setLanguage;
  final GetNotificationsStatus getNotificationsStatus;
  final SetNotificationsStatus setNotificationsStatus;
  final GetThemeMode getThemeMode;
  final SetThemeMode setThemeMode;

  SettingsBloc({
    required this.getLanguage,
    required this.setLanguage,
    required this.getNotificationsStatus,
    required this.setNotificationsStatus,
    required this.getThemeMode,
    required this.setThemeMode,
  }) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<LanguageChanged>(_onLanguageChanged);
    on<NotificationsToggled>(_onNotificationsToggled);
    on<ThemeChanged>(_onThemeChanged);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {


      final results = await Future.wait([
        getLanguage(NoParams()),
        getNotificationsStatus(NoParams()),
        getThemeMode(NoParams()),
      ]);

      final langResult = results[0];
      final notificationsResult = results[1];
      final themeResult = results[2];

      String lang = 'en';
      bool notifications = true;
      String theme = 'system';
      
      langResult.fold((l) => null, (r) => lang = r as String);
      notificationsResult.fold((l) => null, (r) => notifications = r as bool);
      themeResult.fold((l) => null, (r) => theme = r as String);
      
      emit(SettingsLoaded(
        languageCode: lang,
        notificationsEnabled: notifications,
        themeMode: theme,
      ));

    } catch (e) {
      emit(const SettingsFailure('Failed to load settings.'));
    }
  }

  Future<void> _onLanguageChanged(
    LanguageChanged event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await setLanguage(SetLanguageParams(languageCode: event.languageCode));
    result.fold(
      (failure) => emit(const SettingsFailure('Failed to save language.')),
      (_) => add(LoadSettings()),
    );
  }

  Future<void> _onNotificationsToggled(
    NotificationsToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await setNotificationsStatus(SetNotificationsStatusParams(enabled: event.isEnabled));
     result.fold(
      (failure) => emit(const SettingsFailure('Failed to save notification settings.')),
      (_) => add(LoadSettings()),
    );
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await setThemeMode(SetThemeModeParams(themeMode: event.themeMode));
     result.fold(
      (failure) => emit(const SettingsFailure('Failed to save theme settings.')),
      (_) => add(LoadSettings()),
    );
  }
}
