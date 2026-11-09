import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'aerovault_colors.dart';

/// Immutable Theme State containing current ThemeMode and VaultAccent
class ThemeState extends Equatable {
  final ThemeMode mode;
  final VaultAccent accent;

  const ThemeState({
    this.mode = ThemeMode.dark,
    this.accent = VaultAccent.emerald,
  });

  bool get isDark => mode == ThemeMode.dark;

  ThemeState copyWith({
    ThemeMode? mode,
    VaultAccent? accent,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      accent: accent ?? this.accent,
    );
  }

  @override
  List<Object?> get props => [mode, accent];
}

/// BLoC Cubit for dynamic Dark/Light theme mode & brand accent management
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit([super.initialState = const ThemeState()]);

  /// Toggle between Dark Mode and Light Mode
  void toggleTheme() {
    emit(state.copyWith(
      mode: state.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    ));
  }

  /// Switch the active Brand Accent Preset (Emerald, Sapphire, Violet, Gold)
  void setAccent(VaultAccent accent) {
    if (state.accent == accent) return;
    emit(state.copyWith(accent: accent));
  }

  /// Explicitly set the theme mode
  void setThemeMode(ThemeMode mode) {
    if (state.mode == mode) return;
    emit(state.copyWith(mode: mode));
  }
}
