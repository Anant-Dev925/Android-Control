import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

enum AppThemeMode { system, light, dark }

class ThemeState extends Equatable {
  final AppThemeMode themeMode;
  final bool showSyntaxHighlighting;
  final bool autoScroll;
  final int contextLimit;

  const ThemeState({
    this.themeMode = AppThemeMode.system,
    this.showSyntaxHighlighting = true,
    this.autoScroll = true,
    this.contextLimit = 20,
  });

  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? showSyntaxHighlighting,
    bool? autoScroll,
    int? contextLimit,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      showSyntaxHighlighting: showSyntaxHighlighting ?? this.showSyntaxHighlighting,
      autoScroll: autoScroll ?? this.autoScroll,
      contextLimit: contextLimit ?? this.contextLimit,
    );
  }

  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  @override
  List<Object?> get props => [themeMode, showSyntaxHighlighting, autoScroll, contextLimit];
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState());

  void setThemeMode(AppThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
  }

  void toggleSyntaxHighlighting() {
    emit(state.copyWith(showSyntaxHighlighting: !state.showSyntaxHighlighting));
  }

  void toggleAutoScroll() {
    emit(state.copyWith(autoScroll: !state.autoScroll));
  }

  void setContextLimit(int limit) {
    emit(state.copyWith(contextLimit: limit));
  }
}
