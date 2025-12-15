import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Theme Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

/// Load saved theme from storage
class ThemeLoadRequested extends ThemeEvent {
  const ThemeLoadRequested();
}

/// Set specific theme mode
class ThemeChangeRequested extends ThemeEvent {
  final ThemeMode themeMode;

  const ThemeChangeRequested(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}
