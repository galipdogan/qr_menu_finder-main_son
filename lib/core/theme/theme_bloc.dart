import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_menu_finder/core/usecases/usecase.dart';
import 'package:qr_menu_finder/features/settings/domain/usecases/get_theme_mode.dart';
import 'package:qr_menu_finder/features/settings/domain/usecases/set_theme_mode.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final GetThemeMode getThemeMode;
  final SetThemeMode setThemeMode;

  ThemeBloc({
    required this.getThemeMode,
    required this.setThemeMode,
  }) : super(const ThemeState()) {
    on<ThemeLoadRequested>(_onLoadRequested);
    on<ThemeChangeRequested>(_onChangeRequested);

    add(const ThemeLoadRequested());
  }

  Future<void> _onLoadRequested(
    ThemeLoadRequested event,
    Emitter<ThemeState> emit,
  ) async {
    final either = await getThemeMode(NoParams());
    either.fold(
      (failure) {
        // On failure, default to system theme
        emit(state.copyWith(themeMode: ThemeMode.system));
      },
      (themeName) {
        emit(state.copyWith(themeMode: _themeModeFromString(themeName)));
      },
    );
  }

  Future<void> _onChangeRequested(
    ThemeChangeRequested event,
    Emitter<ThemeState> emit,
  ) async {
    // We optimistically update the UI, then save.
    emit(state.copyWith(themeMode: event.themeMode));
    
    // Convert enum to string for saving
    final themeName = event.themeMode.name;
    await setThemeMode(SetThemeModeParams(themeMode: themeName));
  }

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
